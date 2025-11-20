# Data sources
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket       = "r10score-terraform-state-dev"
    key          = "network/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
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
  grafana_vpc_id                   = data.terraform_remote_state.network.outputs.vpc_id
  grafana_vpc_subnet_ids           = data.terraform_remote_state.network.outputs.private_subnet_ids

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
  loki_vpc_id                        = data.terraform_remote_state.network.outputs.vpc_id
  loki_private_subnet_ids            = data.terraform_remote_state.network.outputs.private_subnet_ids
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
  loki_vpc_endpoint_allowed_principals = var.loki_vpc_endpoint_allowed_principals
}

# Data source for current AWS account ID
data "aws_caller_identity" "current" {}
