output "role_name" {
  description = "Nome da IAM Role criada"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "ARN da IAM Role criada"
  value       = aws_iam_role.this.arn
}

output "policy_arn" {
  description = "ARN da política IAM criada (se aplicável)"
  value       = var.policy_json != null ? aws_iam_policy.this[0].arn : null
}

output "attached_managed_policies" {
  description = "Lista de ARNs de políticas gerenciadas anexadas"
  value       = var.managed_policy_arns
}