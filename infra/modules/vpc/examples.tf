# =============================================================================
# Exemplo 1: VPC Simples para Desenvolvimento
# =============================================================================
# module "vpc_dev" {
#   source = "../../modules/vpc"
#
#   environment  = "dev"
#   project_name = "my-project"
#   owner        = "DevOps Team"
#   application  = "infrastructure"
#
#   vpc_cidr           = "10.0.0.0/16"
#   availability_zones = ["us-east-1a", "us-east-1b"]
#
#   enable_nat_gateway = true
#   single_nat_gateway = true  # Economiza custos em dev
#
#   tags = {
#     Environment = "development"
#     CostCenter  = "Infrastructure"
#   }
# }

# =============================================================================
# Exemplo 2: VPC Completa para Produção
# =============================================================================
# module "vpc_prod" {
#   source = "../../modules/vpc"
#
#   environment  = "prod"
#   project_name = "production"
#   owner        = "Platform Team"
#   application  = "infrastructure"
#
#   # VPC Configuration
#   vpc_cidr            = "10.0.0.0/16"
#   availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#
#   # NAT Gateway Configuration (Alta Disponibilidade)
#   enable_nat_gateway = true
#   single_nat_gateway = false  # Um NAT Gateway por AZ para HA
#
#   # Subnets Configuration
#   enable_database_subnets    = true
#   map_public_ip_on_launch    = true
#
#   # VPC Endpoints
#   enable_vpc_endpoints = true
#   vpc_endpoints       = [
#     "s3",
#     "dynamodb",
#     "ec2",
#     "ecr.api",
#     "ecr.dkr",
#     "logs",
#     "sts",
#     "secretsmanager"
#   ]
#
#   # Flow Logs
#   enable_flow_log              = true
#   flow_log_destination_type    = "s3"
#   flow_log_log_destination     = "arn:aws:s3:::prod-vpc-flow-logs/"
#   flow_log_traffic_type        = "ALL"
#
#   # DHCP Options
#   enable_dhcp_options              = true
#   dhcp_options_domain_name         = "example.com"
#   dhcp_options_domain_name_servers = ["10.0.0.2", "10.0.0.3"]
#
#   tags = {
#     Environment = "production"
#     Backup      = "required"
#     CostCenter  = "Infrastructure"
#   }
# }
#
# # Outputs de exemplo
# output "vpc_id" {
#   value = module.vpc_prod.vpc_id
# }
#
# output "public_subnet_ids" {
#   value = module.vpc_prod.public_subnet_ids
# }
#
# output "private_subnet_ids" {
#   value = module.vpc_prod.private_subnet_ids
# }

# =============================================================================
# Exemplo 3: VPC com Flow Logs para CloudWatch Logs
# =============================================================================
# module "vpc_with_flow_logs" {
#   source = "../../modules/vpc"
#
#   environment  = "staging"
#   project_name = "staging-project"
#   owner        = "DevOps Team"
#   application  = "infrastructure"
#
#   vpc_cidr           = "10.0.0.0/16"
#   availability_zones = ["us-east-1a", "us-east-1b"]
#
#   enable_nat_gateway = true
#   single_nat_gateway = false
#
#   # Flow Logs para CloudWatch Logs
#   enable_flow_log              = true
#   flow_log_destination_type    = "cloud-watch-logs"
#   flow_log_log_destination     = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vpc/flow-logs"
#   flow_log_iam_role_arn        = "arn:aws:iam::123456789012:role/VPCFlowLogRole"
#   flow_log_traffic_type        = "ALL"
#
#   tags = {
#     Environment = "staging"
#   }
# }

