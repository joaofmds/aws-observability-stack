# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  vpc_cidr           = var.vpc_cidr
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)

  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway      = var.single_nat_gateway
  enable_database_subnets = var.enable_database_subnets
  enable_vpc_endpoints    = var.enable_vpc_endpoints
  vpc_endpoints           = var.vpc_endpoints
  enable_flow_log         = var.enable_flow_log
}

# ------------------------------------------------------------------------------
# Observability Stack Blueprint
# ------------------------------------------------------------------------------
module "observability" {
  source = "../../modules/observability"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags
  region       = var.region

  # Prometheus Configuration
  prometheus_alias = "central-prometheus"

  # Grafana Configuration
  grafana_enabled_data_sources     = ["CLOUDWATCH", "PROMETHEUS"]
  grafana_authentication_providers = ["AWS_SSO"]
  grafana_account_access_type      = "CURRENT_ACCOUNT"
  grafana_alerting_enabled         = true
  grafana_enable_plugin_management = true
  grafana_vpc_id                   = module.vpc.vpc_id
  grafana_vpc_subnet_ids           = module.vpc.private_subnet_ids

  # Custom Grafana IAM Policy (includes Prometheus, CloudWatch, SNS, SES)
  grafana_custom_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPrometheusAccess"
        Effect = "Allow"
        Action = [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchAccess"
        Effect = "Allow"
        Action = [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "logs:StartQuery",
          "logs:GetQueryResults"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowSelfAssumeRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-grafana-service-role-${var.environment}"
      },
      {
        Sid    = "AllowSESSendEmail"
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowSnsPublishToAlertsTopic"
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.alerts_sns_topic_arn != null ? var.alerts_sns_topic_arn : "*"
      }
    ]
  })

  # Loki Configuration
  enable_loki                        = var.enable_loki
  loki_name_prefix                   = "dev"
  loki_vpc_id                        = module.vpc.vpc_id
  loki_private_subnet_ids            = module.vpc.private_subnet_ids
  loki_ecs_cluster_name              = "dev-loki-cluster"
  loki_desired_count                 = 1
  loki_retention_days                = 30
  loki_cloudwatch_log_retention_days = 3
  loki_capacity_provider_strategies = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 1
    }
  ]
  loki_allowed_cidr_blocks = [
    "10.0.0.0/16"
  ]
  loki_additional_security_group_ids = var.enable_loki ? [module.ecs_deploy.ecs_sg_id] : []
  loki_vpc_endpoint_allowed_principals = var.loki_vpc_endpoint_allowed_principals
}

# ------------------------------------------------------------------------------
# ECS Deploy Blueprint
# ------------------------------------------------------------------------------
module "ecs_deploy" {
  source = "../../modules/ecs-deploy"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  region = var.region

  # Networking
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  alb_sg_id      = var.create_alb ? null : var.alb_security_group_id
  allowed_sg_ids = var.allowed_security_group_ids

  # ALB Creation
  create_alb                           = var.create_alb
  alb_subnet_ids                       = var.create_alb ? module.vpc.public_subnet_ids : []
  alb_internal                         = var.alb_internal
  alb_allowed_cidr_blocks              = var.alb_allowed_cidr_blocks
  alb_enable_https                     = var.alb_enable_https
  alb_certificate_arn                  = var.alb_certificate_arn
  alb_ssl_policy                       = var.alb_ssl_policy
  alb_https_redirect                   = var.alb_https_redirect
  alb_enable_deletion_protection       = var.alb_enable_deletion_protection
  alb_enable_http2                     = var.alb_enable_http2
  alb_enable_cross_zone_load_balancing = var.alb_enable_cross_zone_load_balancing
  alb_idle_timeout                     = var.alb_idle_timeout
  alb_ip_address_type                  = var.alb_ip_address_type
  alb_access_logs_bucket               = var.alb_access_logs_bucket
  alb_access_logs_prefix               = var.alb_access_logs_prefix

  # ALB Listener Rule (for existing ALB)
  listener_arn  = var.create_alb ? null : var.alb_listener_arn
  alb_priority  = var.create_alb ? null : var.alb_priority
  path_patterns = var.alb_path_patterns
  host_headers  = var.alb_host_headers

  # ECS Cluster
  create_cluster = true
  cluster_id     = null
  cluster_name   = "${var.application}-cluster-${var.environment}"

  # ECS Service
  container_port             = var.container_port
  desired_count              = var.desired_count
  capacity_provider_strategy = var.capacity_provider_strategy
  assign_public_ip           = false

  # Task sizing
  task_cpu         = var.task_cpu
  task_memory      = var.task_memory
  container_cpu    = var.container_cpu
  container_memory = var.container_memory

  # Autoscaling (optional)
  enable_autoscaling                = var.enable_autoscaling
  autoscaling_min_capacity          = var.autoscaling_min_capacity
  autoscaling_max_capacity          = var.autoscaling_max_capacity
  autoscaling_cpu_target_value      = var.autoscaling_cpu_target_value
  autoscaling_requests_target_value = var.autoscaling_requests_target_value
  load_balancer_arn_suffix          = var.load_balancer_arn_suffix
  autoscaling_scale_in_cooldown     = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown    = var.autoscaling_scale_out_cooldown

  # FireLens / Logging
  enable_cloudwatch_logs             = true
  enable_firelens                    = var.enable_firelens
  s3_logs_bucket_name                = var.s3_logs_bucket_name
  s3_logs_prefix                     = var.s3_logs_prefix
  s3_logs_storage_class              = var.s3_logs_storage_class
  s3_logs_force_destroy              = var.s3_logs_force_destroy
  s3_logs_transition_to_ia_days      = var.s3_logs_transition_to_ia_days
  s3_logs_transition_to_glacier_days = var.s3_logs_transition_to_glacier_days
  s3_logs_expiration_days            = var.s3_logs_expiration_days

  # ADOT
  enable_metrics       = true
  amp_remote_write_url = module.observability.prometheus_remote_write_endpoint
  amp_workspace_arn    = module.observability.prometheus_workspace_arn

  # Loki integration
  enable_loki            = var.enable_loki
  loki_host              = var.enable_loki ? module.observability.loki_host : null
  loki_port              = var.enable_loki ? module.observability.loki_port : null
  loki_security_group_id = var.enable_loki ? module.observability.loki_task_security_group_id : null

  # Secrets Manager
  create_secret        = var.create_secret
  secret_name_override = var.secret_name_override
  secret_description   = var.secret_description
  secret_string        = var.secret_string
  secret_kms_key_id    = var.secret_kms_key_id
}
