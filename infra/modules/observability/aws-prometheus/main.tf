resource "aws_prometheus_workspace" "this" {
  alias = var.alias
  tags = merge(local.common_tags, {
    Name = "central-prometheus-${var.environment}"
  })
}