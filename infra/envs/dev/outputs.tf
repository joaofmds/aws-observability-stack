output "prometheus_workspace_id" {
  value = module.prometheus.workspace_id
}

output "prometheus_remote_write_endpoint" {
  value = module.prometheus.remote_write_endpoint
}

output "prometheus_workspace_arn" {
  value = module.prometheus.workspace_arn
}

output "loki_nlb_dns_name" {
  description = "DNS name do NLB do Loki"
  value       = module.loki_ecs.loki_nlb_dns_name
}

output "loki_host" {
  description = "Host/DNS usado pelos serviços para se conectar ao Loki"
  value       = module.loki_ecs.loki_nlb_dns_name
}

output "loki_port" {
  description = "Porta HTTP do Loki"
  value       = 3100
}

output "loki_cluster_name" {
  description = "Nome do cluster ECS do Loki"
  value       = module.loki_ecs.ecs_cluster_name
}

output "loki_vpc_endpoint_service_name" {
  description = "Nome do serviço PrivateLink do Loki"
  value       = module.loki_ecs.loki_vpc_endpoint_service_name
}