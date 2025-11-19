# =============================================================================
# ECR Outputs
# =============================================================================
output "ecr_repository_url" {
  description = "URL do repositório ECR criado"
  value       = aws_ecr_repository.this.repository_url
}

output "ecr_repository_arn" {
  description = "ARN do repositório ECR criado"
  value       = aws_ecr_repository.this.arn
}

output "ecr_registry_id" {
  description = "ID do registro AWS associado ao repositório ECR"
  value       = aws_ecr_repository.this.registry_id
}

# =============================================================================
# IAM Outputs
# =============================================================================
output "task_role_name" {
  description = "Nome da IAM Role da task criada"
  value       = aws_iam_role.this.name
}

output "task_role_arn" {
  description = "ARN da IAM Role da task criada"
  value       = aws_iam_role.this.arn
}

output "task_policy_arn" {
  description = "ARN da política IAM criada (se aplicável)"
  value       = var.task_role_policy_json != null ? aws_iam_policy.task_role[0].arn : null
}

# =============================================================================
# ALB Outputs
# =============================================================================
output "listener_rule_arn" {
  description = "ARN da regra de listener criada"
  value       = aws_lb_listener_rule.this.arn
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Nome do Target Group"
  value       = aws_lb_target_group.this.name
}

# =============================================================================
# ECS Outputs
# =============================================================================
output "ecs_service_name" {
  description = "Nome do Serviço ECS"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ARN da definição da task criada"
  value       = module.ecs.task_definition_arn
}

output "ecs_sg_id" {
  description = "ID do Security Group do ECS"
  value       = module.ecs.ecs_sg_id
}

output "ecs_container_port" {
  description = "Porta do container ECS"
  value       = module.ecs.container_port
}

output "ecs_cloudwatch_log_group_name" {
  description = "Nome do Log Group do ECS"
  value       = module.ecs.ecs_cloudwatch_log_group_name
}

# =============================================================================
# ADOT Outputs
# =============================================================================
output "adot_container_definition" {
  description = "JSON do container definition do ADOT"
  value       = module.adot.adot_container_definition
}

# =============================================================================
# Secrets Manager Outputs
# =============================================================================
output "secret_arn" {
  description = "ARN do segredo criado (se aplicável)"
  value       = var.create_secret ? module.secrets_manager[0].secret_arn : null
}

output "secret_name" {
  description = "Nome do segredo criado (se aplicável)"
  value       = var.create_secret ? module.secrets_manager[0].secret_name : null
}

output "secret_id" {
  description = "ID do segredo criado (se aplicável)"
  value       = var.create_secret ? module.secrets_manager[0].secret_id : null
}

# =============================================================================
# FireLens Outputs
# =============================================================================
output "firelens_s3_bucket_name" {
  description = "Nome do bucket S3 utilizado para armazenar os logs via FireLens (se aplicável)"
  value       = var.enable_firelens ? module.firelens[0].firelens_s3_bucket_name : null
}

output "firelens_s3_bucket_arn" {
  description = "ARN do bucket S3 utilizado para logs (se aplicável)"
  value       = var.enable_firelens ? module.firelens[0].firelens_s3_bucket_arn : null
}

# =============================================================================
# Common Outputs
# =============================================================================
output "application_name" {
  description = "Nome da aplicação"
  value       = var.application
}

output "environment" {
  description = "Ambiente de implantação"
  value       = var.environment
}

