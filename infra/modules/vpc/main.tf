resource "aws_vpc" "this" {
  cidr_block                       = var.vpc_cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "this" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )

  depends_on = [aws_vpc.this]
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets[count.index].cidr
  availability_zone       = local.public_subnets[count.index].az
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    local.common_tags,
    var.public_subnet_tags,
    {
      Name                                          = local.public_subnets[count.index].name
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${local.name_prefix}" = "shared"
      Tier                                          = "Public"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets[count.index].cidr
  availability_zone = local.private_subnets[count.index].az

  tags = merge(
    local.common_tags,
    var.private_subnet_tags,
    {
      Name                                          = local.private_subnets[count.index].name
      "kubernetes.io/role/internal-elb"             = "1"
      "kubernetes.io/cluster/${local.name_prefix}" = "shared"
      Tier                                          = "Private"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(local.database_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.database_subnets[count.index].cidr
  availability_zone = local.database_subnets[count.index].az

  tags = merge(
    local.common_tags,
    var.database_subnet_tags,
    {
      Name = local.database_subnets[count.index].name
      Tier = "Database"
    }
  )
}

resource "aws_eip" "nat" {
  count = local.create_nat_gateways && var.enable_internet_gateway ? (var.single_nat_gateway ? 1 : length(local.public_subnets)) : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    var.nat_eip_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = local.create_nat_gateways && var.enable_internet_gateway ? (var.single_nat_gateway ? 1 : length(local.public_subnets)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[var.single_nat_gateway ? 0 : count.index].id

  tags = merge(
    local.common_tags,
    var.nat_gateway_tags,
    {
      Name = "${local.name_prefix}-nat-${var.single_nat_gateway ? "" : "${count.index + 1}-"}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  count = var.create_public_route_table && var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(
    local.common_tags,
    var.public_route_table_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = var.create_public_route_table && var.enable_internet_gateway ? length(aws_subnet.public) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count = var.create_private_route_table && local.create_nat_gateways ? (var.single_nat_gateway ? 1 : length(local.private_subnets)) : 0

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
  }

  tags = merge(
    local.common_tags,
    var.private_route_table_tags,
    {
      Name = "${local.name_prefix}-private-rt-${var.single_nat_gateway ? "" : "${count.index + 1}"}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = var.create_private_route_table && local.create_nat_gateways ? length(aws_subnet.private) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table" "database" {
  count = var.create_database_route_table && var.enable_database_subnets ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    var.database_route_table_tags,
    {
      Name = "${local.name_prefix}-database-rt"
    }
  )
}

resource "aws_route_table_association" "database" {
  count = var.create_database_route_table && var.enable_database_subnets ? length(aws_subnet.database) : 0

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

data "aws_vpc_endpoint_service" "this" {
  for_each = var.enable_vpc_endpoints ? toset(var.vpc_endpoints) : []

  service      = each.value
  service_type = contains(["s3", "dynamodb"], each.value) ? "Gateway" : "Interface"
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = var.enable_vpc_endpoints ? {
    for endpoint in var.vpc_endpoints : endpoint => endpoint
    if contains(["s3", "dynamodb"], endpoint)
  } : {}

  vpc_id            = aws_vpc.this.id
  service_name      = data.aws_vpc_endpoint_service.this[each.value].service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = length(var.vpc_endpoint_route_table_ids) > 0 ? var.vpc_endpoint_route_table_ids : concat(
    var.create_private_route_table ? aws_route_table.private[*].id : [],
    var.create_database_route_table ? aws_route_table.database[*].id : [],
  )

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value}-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.enable_vpc_endpoints ? {
    for endpoint in var.vpc_endpoints : endpoint => endpoint
    if !contains(["s3", "dynamodb"], endpoint)
  } : {}

  vpc_id              = aws_vpc.this.id
  service_name        = data.aws_vpc_endpoint_service.this[each.value].service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint[each.value].id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${each.value}-endpoint"
    }
  )
}

resource "aws_security_group" "vpc_endpoint" {
  for_each = var.enable_vpc_endpoints ? {
    for endpoint in var.vpc_endpoints : endpoint => endpoint
    if !contains(["s3", "dynamodb"], endpoint)
  } : {}

  name        = "${local.name_prefix}-vpc-endpoint-${each.value}-sg"
  description = "Security group for VPC Endpoint ${each.value}"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc-endpoint-${each.value}-sg"
    }
  )
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_log ? 1 : 0

  iam_role_arn         = var.flow_log_destination_type == "cloud-watch-logs" ? var.flow_log_iam_role_arn : null
  log_destination      = var.flow_log_log_destination
  log_destination_type = var.flow_log_destination_type
  traffic_type         = var.flow_log_traffic_type
  vpc_id               = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-flow-log"
    }
  )
}

resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = length(var.dhcp_options_ntp_servers) > 0 ? var.dhcp_options_ntp_servers : null
  netbios_name_servers = length(var.dhcp_options_netbios_name_servers) > 0 ? var.dhcp_options_netbios_name_servers : null
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-dhcp-options"
    }
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

resource "aws_security_group" "default" {
  count = var.create_default_security_groups ? 1 : 0

  name        = var.default_security_group_name
  description = var.default_security_group_description
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${var.default_security_group_name}-sg"
    }
  )
}

