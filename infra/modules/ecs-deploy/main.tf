# Locals for common resources
locals {
  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
  })

  repository_name   = "wiiascend/${var.application}-${var.environment}"
  target_group_name = "${var.application}-tg-${var.environment}"
  task_role_name    = "${var.application}-ecs-task-role-${var.environment}"
  task_policy_name  = "${var.application}-ecs-task-policy-${var.environment}"
}

# ------------------------------------------------------------------------------
# ECR Repository
# ------------------------------------------------------------------------------
resource "aws_ecr_repository" "this" {
  name                 = local.repository_name
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = var.ecr_encryption_type
  }

  tags = merge(local.common_tags, {
    Name = local.repository_name
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.ecr_enable_lifecycle_policy ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantém apenas as últimas ${var.ecr_max_image_count} imagens, exceto as tags protegidas."
        selection = {
          tagStatus     = "tagged"
          countType     = "imageCountMoreThan"
          countNumber   = var.ecr_max_image_count
          tagPrefixList = var.ecr_protected_tags
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Role for ECS Task
# ------------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  name        = local.task_role_name
  description = "IAM Role para a task ECS da aplicação ${var.application}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = local.task_role_name
  })
}

resource "aws_iam_policy" "task_role" {
  count       = var.task_role_policy_json != null ? 1 : 0
  name        = local.task_policy_name
  description = "Política para a task ECS da aplicação ${var.application}"
  policy      = var.task_role_policy_json

  tags = merge(local.common_tags, {
    Name = local.task_policy_name
  })
}

resource "aws_iam_role_policy_attachment" "task_role" {
  count      = var.task_role_policy_json != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.task_role[0].arn
}

resource "aws_iam_role_policy_attachment" "task_managed" {
  for_each   = toset(var.task_managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

# ------------------------------------------------------------------------------
# Secrets Manager (Optional)
# ------------------------------------------------------------------------------
module "secrets_manager" {
  count  = var.create_secret ? 1 : 0
  source = "./secrets-manager"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  name_override = var.secret_name_override
  description   = var.secret_description
  secret_string = var.secret_string
  kms_key_id    = var.secret_kms_key_id
}

# ------------------------------------------------------------------------------
# FireLens Module (Optional)
# ------------------------------------------------------------------------------
module "firelens" {
  count  = var.enable_firelens ? 1 : 0
  source = "./firelens"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  enable_cloudwatch_logs             = var.enable_cloudwatch_logs
  s3_logs_bucket_name                = var.s3_logs_bucket_name
  s3_logs_force_destroy              = var.s3_logs_force_destroy
  s3_logs_prefix                     = var.s3_logs_prefix
  s3_logs_storage_class              = var.s3_logs_storage_class
  s3_logs_transition_to_ia_days      = var.s3_logs_transition_to_ia_days
  s3_logs_transition_to_glacier_days = var.s3_logs_transition_to_glacier_days
  s3_logs_expiration_days            = var.s3_logs_expiration_days
  s3_logs_kms_key_arn                = var.s3_logs_kms_key_arn
  firelens_image                     = var.firelens_image
  firelens_cpu                       = var.firelens_cpu
  firelens_memory                    = var.firelens_memory
  firelens_send_own_logs_to_cw       = var.firelens_send_own_logs_to_cw
  fluent_total_file_size             = var.fluent_total_file_size
  fluent_upload_timeout              = var.fluent_upload_timeout
  fluent_compression                 = var.fluent_compression
  s3_logs_config_key                 = var.s3_logs_config_key
  retention_in_days                  = var.retention_in_days
  kms_key_id                         = var.kms_key_id
  metric_filters                     = var.metric_filters
  destination_arn                    = var.destination_arn
  subscription_filter_pattern        = var.subscription_filter_pattern
  subscription_role_arn              = var.subscription_role_arn
  aws_resource                       = var.aws_resource
  enable_loki                        = var.enable_loki
  loki_host                          = var.loki_host
  loki_port                          = var.loki_port
  loki_tls                           = var.loki_tls
  loki_tenant_id                     = var.loki_tenant_id
  task_role_name                     = aws_iam_role.this.name
}

# ------------------------------------------------------------------------------
# ADOT Module
# ------------------------------------------------------------------------------
module "adot" {
  source = "./adot"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  region                = var.region
  assume_role_arn       = var.adot_assume_role_arn
  amp_remote_write_url  = var.amp_remote_write_url
  log_group             = var.log_group
  log_stream_prefix     = var.log_stream_prefix
  volume_name           = var.volume_name
  image                 = var.adot_image
  adot_cpu              = var.adot_cpu
  adot_memory           = var.adot_memory
  enable_traces         = var.enable_traces
  enable_metrics        = var.enable_metrics
  environment_variables = var.adot_environment_variables
  container_name        = var.adot_container_name
}

# ------------------------------------------------------------------------------
# ALB Target Group and Listener Rule
# ------------------------------------------------------------------------------
resource "aws_lb_target_group" "this" {
  name        = local.target_group_name
  port        = var.container_port
  protocol    = var.alb_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  tags = merge(local.common_tags, {
    Name = local.target_group_name
  })
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.alb_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  dynamic "condition" {
    for_each = var.host_headers != [] ? [1] : []
    content {
      host_header {
        values = var.host_headers
      }
    }
  }
}

# ------------------------------------------------------------------------------
# ECS Service and Task Definition
# ------------------------------------------------------------------------------
module "ecs" {
  source = "./ecs"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  cluster_id                 = var.cluster_id
  cluster_name               = var.cluster_name
  task_cpu                   = var.task_cpu
  task_memory                = var.task_memory
  container_cpu              = var.container_cpu
  container_memory           = var.container_memory
  execution_role_arn         = var.execution_role_arn
  task_role_arn              = aws_iam_role.this.arn
  desired_count              = var.desired_count
  subnet_ids                 = var.subnet_ids
  assign_public_ip           = var.assign_public_ip
  container_name             = var.application
  container_port             = var.container_port
  vpc_id                     = var.vpc_id
  alb_sg_id                  = var.alb_sg_id
  allowed_sg_ids             = var.allowed_sg_ids
  ecs_execution_role_name    = var.ecs_execution_role_name
  capacity_provider_strategy = var.capacity_provider_strategy
  volumes                    = var.volumes
  ecs_environment_variables  = var.ecs_environment_variables
  ecs_secrets = concat(
    var.ecs_secrets,
    var.create_secret ? [
      {
        name      = "SECRET_MANAGER_ARN"
        valueFrom = module.secrets_manager[0].secret_arn
      }
    ] : []
  )
  enable_autoscaling                = var.enable_autoscaling
  autoscaling_min_capacity          = var.autoscaling_min_capacity
  autoscaling_max_capacity          = var.autoscaling_max_capacity
  autoscaling_cpu_target_value      = var.autoscaling_cpu_target_value
  autoscaling_requests_target_value = var.autoscaling_requests_target_value
  load_balancer_arn_suffix          = var.load_balancer_arn_suffix
  autoscaling_scale_in_cooldown     = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown    = var.autoscaling_scale_out_cooldown
  log_group                         = var.log_group
  region                            = var.region
  enable_firelens                   = var.enable_firelens
  enable_loki                       = var.enable_loki
  enable_cloudwatch_logs            = var.enable_cloudwatch_logs
  loki_host                         = var.loki_host
  loki_port                         = var.loki_port
  loki_tls                          = var.loki_tls
  loki_tenant_id                    = var.loki_tenant_id
  s3_logs_bucket_name               = var.enable_firelens ? module.firelens[0].firelens_s3_bucket_name : null
  s3_logs_prefix                    = var.s3_logs_prefix
  s3_logs_storage_class             = var.s3_logs_storage_class
  fluent_total_file_size            = var.fluent_total_file_size
  fluent_upload_timeout             = var.fluent_upload_timeout
  fluent_compression                = var.fluent_compression
  firelens_image                    = var.firelens_image
  firelens_cpu                      = var.firelens_cpu
  firelens_memory                   = var.firelens_memory
  firelens_send_own_logs_to_cw      = var.firelens_send_own_logs_to_cw
  adot_container_definition_json    = module.adot.adot_container_definition

  depends_on = [
    aws_ecr_repository.this,
    aws_iam_role.this,
    aws_lb_target_group.this,
    module.adot,
    module.firelens
  ]
}
