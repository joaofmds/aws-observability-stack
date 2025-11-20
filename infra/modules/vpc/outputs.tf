# =============================================================================
# VPC Outputs
# =============================================================================
output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN da VPC criada"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block da VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_default_security_group_id" {
  description = "ID do Security Group padrão da VPC"
  value       = aws_vpc.this.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "ID da Route Table padrão da VPC"
  value       = aws_vpc.this.default_route_table_id
}

output "vpc_main_route_table_id" {
  description = "ID da Route Table principal da VPC"
  value       = aws_vpc.this.main_route_table_id
}

# =============================================================================
# Internet Gateway Outputs
# =============================================================================
output "internet_gateway_id" {
  description = "ID do Internet Gateway (se criado)"
  value       = var.enable_internet_gateway ? aws_internet_gateway.this[0].id : null
}

output "internet_gateway_arn" {
  description = "ARN do Internet Gateway (se criado)"
  value       = var.enable_internet_gateway ? aws_internet_gateway.this[0].arn : null
}

# =============================================================================
# NAT Gateway Outputs
# =============================================================================
output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways criados"
  value       = aws_nat_gateway.this[*].id
}

output "nat_gateway_arns" {
  description = "ARNs dos NAT Gateways criados"
  value       = aws_nat_gateway.this[*].arn
}

output "nat_public_ips" {
  description = "Elastic IPs públicos dos NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# =============================================================================
# Subnet Outputs
# =============================================================================
output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "ARNs das subnets públicas"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidrs" {
  description = "CIDR blocks das subnets públicas"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "ARNs das subnets privadas"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidrs" {
  description = "CIDR blocks das subnets privadas"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "IDs das subnets de banco de dados (se criadas)"
  value       = aws_subnet.database[*].id
}

output "database_subnet_arns" {
  description = "ARNs das subnets de banco de dados (se criadas)"
  value       = aws_subnet.database[*].arn
}

output "database_subnet_cidrs" {
  description = "CIDR blocks das subnets de banco de dados (se criadas)"
  value       = aws_subnet.database[*].cidr_block
}

# =============================================================================
# Route Table Outputs
# =============================================================================
output "public_route_table_id" {
  description = "ID da Route Table pública (se criada)"
  value       = var.create_public_route_table && var.enable_internet_gateway ? aws_route_table.public[0].id : null
}

output "public_route_table_ids" {
  description = "IDs das Route Tables públicas"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "IDs das Route Tables privadas"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID da Route Table de banco de dados (se criada)"
  value       = var.create_database_route_table && var.enable_database_subnets ? aws_route_table.database[0].id : null
}

# =============================================================================
# VPC Endpoint Outputs
# =============================================================================
output "vpc_endpoint_ids" {
  description = "IDs dos VPC Endpoints criados"
  value       = merge(aws_vpc_endpoint.gateway, aws_vpc_endpoint.interface)
}

output "vpc_endpoint_arns" {
  description = "ARNs dos VPC Endpoints criados"
  value = merge(
    { for k, v in aws_vpc_endpoint.gateway : k => v.arn },
    { for k, v in aws_vpc_endpoint.interface : k => v.arn }
  )
}

# =============================================================================
# Flow Log Outputs
# =============================================================================
output "flow_log_id" {
  description = "ID do Flow Log (se criado)"
  value       = var.enable_flow_log ? aws_flow_log.this[0].id : null
}

# =============================================================================
# DHCP Options Outputs
# =============================================================================
output "dhcp_options_id" {
  description = "ID do DHCP Options Set (se criado)"
  value       = var.enable_dhcp_options ? aws_vpc_dhcp_options.this[0].id : null
}

# =============================================================================
# Security Group Outputs
# =============================================================================
output "default_security_group_id" {
  description = "ID do Security Group padrão criado (se criado)"
  value       = var.create_default_security_groups ? aws_security_group.default[0].id : null
}

# =============================================================================
# Availability Zones
# =============================================================================
output "availability_zones" {
  description = "Availability Zones utilizadas"
  value       = var.availability_zones
}

# =============================================================================
# Common Outputs
# =============================================================================
output "name_prefix" {
  description = "Prefixo de nome usado nos recursos"
  value       = local.name_prefix
}

