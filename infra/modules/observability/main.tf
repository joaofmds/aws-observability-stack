# Locals for common resources
locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
  })
}

# ------------------------------------------------------------------------------
# IAM Role for Grafana Service
# ------------------------------------------------------------------------------
module "grafana_service_role" {
  source = "./aws-iam-role"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  role_name        = "grafana-service-role"
  policy_name      = "grafana-service-policy"
  role_description = "IAM Role para o Amazon Managed Grafana acessar serviços AWS"
  assume_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "grafana.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  policy_json         = var.grafana_custom_policy_json
  policy_description  = var.grafana_custom_policy_json != null ? "Política customizada para o Grafana" : null
  managed_policy_arns = var.grafana_managed_policy_arns
  prevent_destroy     = false
}

# ------------------------------------------------------------------------------
# Amazon Managed Prometheus (AMP)
# ------------------------------------------------------------------------------
module "prometheus" {
  source = "./aws-prometheus"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  alias  = var.prometheus_alias
  region = var.region
}

# ------------------------------------------------------------------------------
# Amazon Managed Grafana
# ------------------------------------------------------------------------------
module "grafana" {
  source = "./aws-grafana"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  enabled_data_sources     = var.grafana_enabled_data_sources
  grafana_service_role_arn = module.grafana_service_role.role_arn
  authentication_providers = var.grafana_authentication_providers
  account_access_type      = var.grafana_account_access_type
  grafana_alerting_enabled = var.grafana_alerting_enabled
  enable_plugin_management = var.grafana_enable_plugin_management
  name_prefix              = var.grafana_name_prefix
  vpc_id                   = var.grafana_vpc_id
  vpc_subnet_ids           = var.grafana_vpc_subnet_ids

  depends_on = [
    module.grafana_service_role
  ]
}

# ------------------------------------------------------------------------------
# Loki on ECS (Optional)
# ------------------------------------------------------------------------------
module "loki" {
  count  = var.enable_loki ? 1 : 0
  source = "./aws-loki-ecs"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  name_prefix                     = var.loki_name_prefix
  vpc_id                          = var.loki_vpc_id
  private_subnet_ids              = var.loki_private_subnet_ids
  ecs_cluster_name                = var.loki_ecs_cluster_name
  create_s3_bucket                = var.loki_create_s3_bucket
  s3_bucket_name                  = var.loki_s3_bucket_name
  s3_bucket_kms_key_arn           = var.loki_s3_bucket_kms_key_arn
  loki_image                      = var.loki_image
  loki_cpu                        = var.loki_cpu
  loki_memory                     = var.loki_memory
  loki_desired_count              = var.loki_desired_count
  loki_port                       = var.loki_port
  retention_days                  = var.loki_retention_days
  allowed_cidr_blocks             = var.loki_allowed_cidr_blocks
  # Adiciona automaticamente o security group do Grafana se estiver configurado com VPC
  allowed_security_group_ids      = concat(
    var.loki_allowed_security_group_ids,
    var.grafana_vpc_id != null && module.grafana.grafana_workspace_security_group_id != null ? [module.grafana.grafana_workspace_security_group_id] : []
  )
  capacity_provider_strategies    = var.loki_capacity_provider_strategies
  cloudwatch_log_retention_days   = var.loki_cloudwatch_log_retention_days
  vpc_endpoint_allowed_principals = var.loki_vpc_endpoint_allowed_principals

  depends_on = [
    module.grafana
  ]
}

