output "workspace_id" {
  description = "ID do workspace AMP"
  value       = aws_prometheus_workspace.this.id
}

output "workspace_arn" {
  description = "ARN do workspace AMP"
  value       = aws_prometheus_workspace.this.arn
}

output "remote_write_endpoint" {
  description = "Endpoint para uso com ADOT / Prometheus Remote Write"
  value       = "https://aps-workspaces.${var.region}.amazonaws.com/workspaces/${aws_prometheus_workspace.this.id}/api/v1/remote_write"
}

output "query_endpoint" {
  description = "Endpoint para consultas (Grafana ou Prometheus UI)"
  value       = "https://aps-workspaces.${var.region}.amazonaws.com/workspaces/${aws_prometheus_workspace.this.id}/api/v1/query"
}