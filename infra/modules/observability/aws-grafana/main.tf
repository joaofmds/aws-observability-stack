resource "aws_security_group" "workspace" {
  count       = var.vpc_id == null ? 0 : 1
  name        = "${local.name}-workspace-sg"
  description = "Security group para Amazon Managed Grafana workspace acessar datasources privados"
  vpc_id      = var.vpc_id

  # Apenas egress, retorno é stateful
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

  # Só configura VPC se vpc_id e subnets forem fornecidos
  dynamic "vpc_configuration" {
    for_each = var.vpc_id != null && length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = [aws_security_group.workspace[0].id]
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name}-${var.environment}"
  })
}
