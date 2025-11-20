# =============================================================================
# Observability Outputs
# =============================================================================
output "prometheus_workspace_id" {
  description = "ID do workspace AMP"
  value       = module.observability.prometheus_workspace_id
}

output "prometheus_remote_write_endpoint" {
  description = "Endpoint para uso com ADOT / Prometheus Remote Write"
  value       = module.observability.prometheus_remote_write_endpoint
}

output "prometheus_workspace_arn" {
  description = "ARN do workspace AMP"
  value       = module.observability.prometheus_workspace_arn
}

output "prometheus_query_endpoint" {
  description = "Endpoint para consultas (Grafana ou Prometheus UI)"
  value       = module.observability.prometheus_query_endpoint
}

output "grafana_workspace_url" {
  description = "URL do workspace Grafana"
  value       = module.observability.grafana_workspace_url
}

output "grafana_workspace_id" {
  description = "ID do workspace Grafana"
  value       = module.observability.grafana_workspace_id
}

output "grafana_workspace_arn" {
  description = "ARN do workspace Grafana"
  value       = module.observability.grafana_workspace_arn
}

output "grafana_service_role_arn" {
  description = "ARN da IAM Role do serviço Grafana"
  value       = module.observability.grafana_service_role_arn
}

# =============================================================================
# Loki Outputs
# =============================================================================
output "loki_nlb_dns_name" {
  description = "DNS name do NLB do Loki"
  value       = var.enable_loki ? module.observability.loki_nlb_dns_name : null
}

output "loki_host" {
  description = "Host/DNS usado pelos serviços para se conectar ao Loki"
  value       = var.enable_loki ? module.observability.loki_nlb_dns_name : null
}

output "loki_port" {
  description = "Porta HTTP do Loki"
  value       = 3100
}

output "loki_endpoint_http" {
  description = "Endpoint HTTP do Loki (sem TLS, dentro da VPC)"
  value       = var.enable_loki ? module.observability.loki_endpoint_http : null
}

output "loki_cluster_name" {
  description = "Nome do cluster ECS do Loki"
  value       = var.enable_loki ? module.observability.loki_ecs_cluster_name : null
}

output "loki_ecs_cluster_arn" {
  description = "ARN do cluster ECS do Loki"
  value       = var.enable_loki ? module.observability.loki_ecs_cluster_arn : null
}

output "loki_vpc_endpoint_service_name" {
  description = "Nome do serviço PrivateLink do Loki"
  value       = var.enable_loki ? module.observability.loki_vpc_endpoint_service_name : null
}

output "loki_s3_bucket_name" {
  description = "Nome do bucket S3 utilizado pelo Loki"
  value       = var.enable_loki ? module.observability.loki_s3_bucket_name : null
}

# =============================================================================
# ECS Deploy Outputs
# =============================================================================
output "ecs_service_name" {
  description = "Nome do Serviço ECS criado"
  value       = module.ecs_deploy.ecs_service_name
}

output "ecs_task_definition_arn" {
  description = "ARN da task definition em uso"
  value       = module.ecs_deploy.ecs_task_definition_arn
}

output "ecs_security_group_id" {
  description = "Security group do serviço ECS"
  value       = module.ecs_deploy.ecs_security_group_id
}

output "ecs_cluster_id" {
  description = "ID do cluster ECS utilizado"
  value       = module.ecs_deploy.ecs_cluster_id
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs_deploy.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster, se criado pelo módulo"
  value       = module.ecs_deploy.ecs_cluster_arn
}

