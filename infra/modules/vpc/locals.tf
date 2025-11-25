locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
    ManagedBy   = "Terraform"
  })

  name_prefix = "${var.project_name}-${var.environment}"

  create_nat_gateways = var.enable_nat_gateway && length(var.availability_zones) > 0

  public_subnet_newbits    = 8
  private_subnet_newbits   = 8
  database_subnet_newbits  = 8

  public_subnets = [
    for i, az in var.availability_zones : {
      cidr        = cidrsubnet(var.vpc_cidr, local.public_subnet_newbits, i)
      az          = az
      name        = "${local.name_prefix}-public-${substr(az, -1, 1)}"
      subnet_type = "public"
    }
  ]

  private_subnets = [
    for i, az in var.availability_zones : {
      cidr        = cidrsubnet(var.vpc_cidr, local.private_subnet_newbits, i + 16)
      az          = az
      name        = "${local.name_prefix}-private-${substr(az, -1, 1)}"
      subnet_type = "private"
    }
  ]

  database_subnets = var.enable_database_subnets ? [
    for i, az in var.availability_zones : {
      cidr        = cidrsubnet(var.vpc_cidr, local.database_subnet_newbits, i + 32)
      az          = az
      name        = "${local.name_prefix}-database-${substr(az, -1, 1)}"
      subnet_type = "database"
    }
  ] : []
}

