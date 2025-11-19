output "loki_service_name" {
  description = "Nome do serviço ECS do Loki"
  value       = aws_ecs_service.loki.name
}

output "loki_task_definition_arn" {
  description = "ARN da task definition do Loki"
  value       = aws_ecs_task_definition.loki.arn
}

output "loki_nlb_arn" {
  description = "ARN do Network Load Balancer do Loki"
  value       = aws_lb.loki.arn
}

output "loki_nlb_dns_name" {
  description = "DNS do NLB do Loki"
  value       = aws_lb.loki.dns_name
}

output "loki_endpoint_http" {
  description = "Endpoint HTTP do Loki (sem TLS, dentro da VPC)"
  value       = "http://${aws_lb.loki.dns_name}:${var.loki_port}"
}

output "loki_s3_bucket_name" {
  description = "Nome do bucket S3 utilizado pelo Loki"
  value       = local.loki_s3_bucket_name
}

output "loki_task_security_group_id" {
  description = "ID do Security Group das tasks ECS do Loki"
  value       = aws_security_group.loki_tasks.id
}

output "loki_target_group_arn" {
  description = "ARN do target group do Loki"
  value       = aws_lb_target_group.loki.arn
}

output "loki_cloudwatch_log_group_name" {
  description = "Nome do log group do Loki no CloudWatch"
  value       = aws_cloudwatch_log_group.loki.name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS criado para o Loki"
  value       = aws_ecs_cluster.loki.arn
}

output "ecs_cluster_name" {
  description = "Nome do cluster ECS criado para o Loki"
  value       = aws_ecs_cluster.loki.name
}

output "loki_vpc_endpoint_service_name" {
  description = "Nome do VPC Endpoint Service (PrivateLink) para o Loki, usado pelas VPCs consumidoras"
  value       = aws_vpc_endpoint_service.loki.service_name
}
