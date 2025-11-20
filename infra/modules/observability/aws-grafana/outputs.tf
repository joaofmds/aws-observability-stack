output "grafana_workspace_url" {
  description = "URL do workspace Grafana"
  value       = aws_grafana_workspace.this.endpoint
}

output "grafana_workspace_id" {
  description = "ID do workspace Grafana"
  value       = aws_grafana_workspace.this.id
}

output "grafana_workspace_arn" {
  description = "ARN do workspace Grafana"
  value       = aws_grafana_workspace.this.arn
}

output "grafana_workspace_security_group_id" {
  description = "Security Group anexado aos ENIs do workspace Grafana (se vpc_configuration estiver habilitada)"
  value       = length(aws_security_group.workspace) > 0 ? aws_security_group.workspace[0].id : null
}
