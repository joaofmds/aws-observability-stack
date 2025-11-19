locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
  })

  role_name = "${var.application}-${var.role_name}-${var.environment}"
  
  policy_name = "${var.application}-${var.policy_name}-${var.environment}"
}

