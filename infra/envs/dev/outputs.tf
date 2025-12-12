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
  value       = module.ecs_deploy.ecs_sg_id
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

output "alb_arn" {
  description = "ARN do Application Load Balancer (se criado)"
  value       = module.ecs_deploy.alb_arn
}

output "alb_dns_name" {
  description = "DNS name do Application Load Balancer (se criado)"
  value       = module.ecs_deploy.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID do Application Load Balancer (se criado)"
  value       = module.ecs_deploy.alb_zone_id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB (se criado)"
  value       = module.ecs_deploy.alb_security_group_id
}

output "http_listener_arn" {
  description = "ARN do listener HTTP (se criado)"
  value       = module.ecs_deploy.http_listener_arn
}

output "https_listener_arn" {
  description = "ARN do listener HTTPS (se criado)"
  value       = module.ecs_deploy.https_listener_arn
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = module.ecs_deploy.target_group_arn
}

output "target_group_name" {
  description = "Nome do Target Group"
  value       = module.ecs_deploy.target_group_name
}

output "target_group_id" {
  description = "ID do Target Group"
  value       = module.ecs_deploy.target_group_id
}

output "vpc_id" {
  description = "ID da VPC (from network module remote state)"
  value       = data.terraform_remote_state.network.outputs.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas (from network module remote state)"
  value       = data.terraform_remote_state.network.outputs.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas/app (from network module remote state)"
  value       = data.terraform_remote_state.network.outputs.app_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs das subnets de aplicação (from network module remote state)"
  value       = data.terraform_remote_state.network.outputs.app_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways (from network module remote state)"
  value       = data.terraform_remote_state.network.outputs.nat_gateway_ids
}

# Outputs relacionados ao Observability (via remote states)
output "prometheus_workspace_id" {
  description = "ID do workspace AMP (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.prometheus_workspace_id
}

output "prometheus_remote_write_endpoint" {
  description = "Endpoint para uso com ADOT / Prometheus Remote Write (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.prometheus_remote_write_endpoint
}

output "prometheus_workspace_arn" {
  description = "ARN do workspace AMP (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.prometheus_workspace_arn
}

output "prometheus_query_endpoint" {
  description = "Endpoint para consultas (Grafana ou Prometheus UI) (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.prometheus_query_endpoint
}

output "grafana_workspace_url" {
  description = "URL do workspace Grafana (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.grafana_workspace_url
}

output "grafana_workspace_id" {
  description = "ID do workspace Grafana (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.grafana_workspace_id
}

output "grafana_workspace_arn" {
  description = "ARN do workspace Grafana (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.grafana_workspace_arn
}

output "grafana_service_role_arn" {
  description = "ARN da IAM Role do serviço Grafana (from observability/prod remote state)"
  value       = data.terraform_remote_state.observability_prod.outputs.grafana_service_role_arn
}

output "loki_vpce_dns_name" {
  description = "DNS do VPC Endpoint do Loki (from observability/dev remote state)"
  value       = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_dns_name : null
}

output "loki_vpce_id" {
  description = "ID do VPC Endpoint do Loki (from observability/dev remote state)"
  value       = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_id : null
}

output "loki_vpce_security_group_id" {
  description = "ID do Security Group do VPC Endpoint do Loki (from observability/dev remote state)"
  value       = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_security_group_id : null
}

output "loki_host" {
  description = "Host (DNS) do Loki via VPC Endpoint (from observability/dev remote state)"
  value       = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_dns_name : null
}

output "loki_port" {
  description = "Porta HTTP do Loki"
  value       = var.enable_loki ? 3100 : null
}

