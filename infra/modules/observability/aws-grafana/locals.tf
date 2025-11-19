locals {
  name            = var.name_prefix != null ? "${var.name_prefix}-grafana-${var.project_name}-${var.environment}" : "grafana-${var.project_name}-${var.environment}"
  enabled_sources = toset(var.enabled_data_sources)
  common_tags = merge(var.tags, {
    Name        = local.name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner,
    Application = var.application
  })
}