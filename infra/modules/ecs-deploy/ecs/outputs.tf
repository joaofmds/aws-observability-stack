output "service_name" {
  value       = aws_ecs_service.this.name
  description = "Nome do Serviço ECS."
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ARN da definição da task criada."
}

output "ecs_sg_id" {
  description = "ID do Security Group do ECS"
  value       = aws_security_group.ecs_sg.id
}

output "container_port" {
  description = "Porta do container ECS"
  value       = var.container_port
}

output "ecs_cloudwatch_log_group_name" {
  description = "Nome do Log Group do ECS"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.this[0].name : null
}