resource "aws_security_group" "workspace" {
  count = length(var.vpc_subnet_ids) > 0 ? 1 : 0

  name        = "${local.name}-workspace-sg"
  description = "Security group para Amazon Managed Grafana workspace acessar datasources privados"
  vpc_id      = length(var.vpc_subnet_ids) > 0 ? var.vpc_id : null

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-workspace-sg"
  })
}

resource "aws_grafana_workspace" "this" {
  name                     = local.name
  account_access_type      = var.account_access_type
  authentication_providers = var.authentication_providers
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = var.grafana_service_role_arn

  configuration = jsonencode(merge(
    {
      unifiedAlerting = {
        enabled = var.grafana_alerting_enabled
      }
    },
    {
      plugins = {
        pluginAdminEnabled = var.enable_plugin_management
      }
    }
  ))

  dynamic "vpc_configuration" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = length(aws_security_group.workspace) > 0 ? [aws_security_group.workspace[0].id] : []
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-${var.environment}"
  })
}
