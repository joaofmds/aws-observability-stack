output "grafana_service_role_name" {
  description = "Nome da IAM Role do serviço Grafana"
  value       = module.grafana_service_role.role_name
}

output "grafana_service_role_arn" {
  description = "ARN da IAM Role do serviço Grafana"
  value       = module.grafana_service_role.role_arn
}

output "grafana_service_policy_arn" {
  description = "ARN da política IAM criada para o Grafana (se aplicável)"
  value       = module.grafana_service_role.policy_arn
}

output "prometheus_workspace_id" {
  description = "ID do workspace AMP"
  value       = module.prometheus.workspace_id
}

output "prometheus_workspace_arn" {
  description = "ARN do workspace AMP"
  value       = module.prometheus.workspace_arn
}

output "prometheus_remote_write_endpoint" {
  description = "Endpoint para uso com ADOT / Prometheus Remote Write"
  value       = module.prometheus.remote_write_endpoint
}

output "prometheus_query_endpoint" {
  description = "Endpoint para consultas (Grafana ou Prometheus UI)"
  value       = module.prometheus.query_endpoint
}

output "grafana_workspace_url" {
  description = "URL do workspace Grafana"
  value       = module.grafana.grafana_workspace_url
}

output "grafana_workspace_id" {
  description = "ID do workspace Grafana"
  value       = module.grafana.grafana_workspace_id
}

output "grafana_workspace_arn" {
  description = "ARN do workspace Grafana"
  value       = module.grafana.grafana_workspace_arn
}

output "grafana_workspace_security_group_id" {
  description = "Security Group anexado aos ENIs do workspace Grafana (se vpc_configuration estiver habilitada)"
  value       = module.grafana.grafana_workspace_security_group_id
}

output "loki_service_name" {
  description = "Nome do serviço ECS do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_service_name : null
}

output "loki_task_definition_arn" {
  description = "ARN da task definition do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_task_definition_arn : null
}

output "loki_nlb_arn" {
  description = "ARN do Network Load Balancer do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_nlb_arn : null
}

output "loki_nlb_dns_name" {
  description = "DNS do NLB do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_nlb_dns_name : null
}

output "loki_endpoint_http" {
  description = "Endpoint HTTP do Loki (sem TLS, dentro da VPC) (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_endpoint_http : null
}

output "loki_s3_bucket_name" {
  description = "Nome do bucket S3 utilizado pelo Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_s3_bucket_name : null
}

output "loki_task_security_group_id" {
  description = "ID do Security Group das tasks ECS do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_task_security_group_id : null
}

output "loki_target_group_arn" {
  description = "ARN do target group do Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_target_group_arn : null
}

output "loki_cloudwatch_log_group_name" {
  description = "Nome do log group do Loki no CloudWatch (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_cloudwatch_log_group_name : null
}

output "loki_ecs_cluster_arn" {
  description = "ARN do cluster ECS criado para o Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].ecs_cluster_arn : null
}

output "loki_ecs_cluster_name" {
  description = "Nome do cluster ECS criado para o Loki (se aplicável)"
  value       = var.enable_loki ? module.loki[0].ecs_cluster_name : null
}

output "loki_vpc_endpoint_service_name" {
  description = "Nome do VPC Endpoint Service (PrivateLink) para o Loki, usado pelas VPCs consumidoras (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_vpc_endpoint_service_name : null
}

output "loki_host" {
  description = "Host (DNS) do Loki NLB (se aplicável)"
  value       = var.enable_loki ? module.loki[0].loki_nlb_dns_name : null
}

output "loki_port" {
  description = "Porta HTTP do Loki (se aplicável)"
  value       = var.enable_loki ? var.loki_port : null
}

output "environment" {
  description = "Ambiente de implantação"
  value       = var.environment
}

output "project_name" {
  description = "Nome do projeto"
  value       = var.project_name
}

