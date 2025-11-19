data "aws_region" "current" {}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  base_name = "${var.name_prefix}-loki"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Application = var.application
  })

  bucket_name_generated = lower("${var.name_prefix}-loki-${random_id.bucket_suffix.hex}")
  loki_s3_bucket_name   = var.create_s3_bucket ? coalesce(var.s3_bucket_name, local.bucket_name_generated) : var.s3_bucket_name

  loki_s3_bucket_arn = var.create_s3_bucket ? aws_s3_bucket.loki[0].arn : "arn:aws:s3:::${local.loki_s3_bucket_name}"
}

# ---------------------------------------------------------------------------
# S3 bucket para storage do Loki
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "loki" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = local.loki_s3_bucket_name

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.loki[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_bucket_kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.s3_bucket_kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "loki" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.loki[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# IAM Roles
# ---------------------------------------------------------------------------

resource "aws_iam_role" "task_execution" {
  name = "${local.base_name}-exec-role"

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
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_base" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name = "${local.base_name}-task-role"

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
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_iam_role_policy" "task_s3_access" {
  name = "${local.base_name}-s3-access"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [local.loki_s3_bucket_arn]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = ["${local.loki_s3_bucket_arn}/*"]
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# CloudWatch Logs somente para o container Loki (debug)
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "loki" {
  name              = "/ecs/${local.base_name}"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

# ---------------------------------------------------------------------------
# Security Group para tasks ECS (Loki)
# ---------------------------------------------------------------------------

resource "aws_security_group" "loki_tasks" {
  name        = "${local.base_name}-tasks-sg"
  description = "Security group para tasks ECS do Loki"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_security_group_rule" "loki_ingress_cidr" {
  for_each = toset(var.allowed_cidr_blocks)

  type              = "ingress"
  from_port         = var.loki_port
  to_port           = var.loki_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.loki_tasks.id
}

resource "aws_security_group_rule" "loki_ingress_sg" {
  for_each = toset(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = var.loki_port
  to_port                  = var.loki_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.loki_tasks.id
}

# ---------------------------------------------------------------------------
# ECS Cluster para Loki
# ---------------------------------------------------------------------------

resource "aws_ecs_cluster" "loki" {
  name = local.base_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_ecs_cluster_capacity_providers" "loki" {
  count = length(var.capacity_provider_strategies) > 0 ? 1 : 0

  cluster_name       = aws_ecs_cluster.loki.name
  capacity_providers = distinct([for s in var.capacity_provider_strategies : s.capacity_provider])

  dynamic "default_capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight            = try(default_capacity_provider_strategy.value.weight, null)
      base              = try(default_capacity_provider_strategy.value.base, null)
    }
  }
}

# ---------------------------------------------------------------------------
# Loki config (YAML) + script de entrypoint
# ---------------------------------------------------------------------------

locals {
  loki_config_yaml = templatefile("${path.module}/templates/loki-config.yaml.tpl", {
    s3_bucket_name = local.loki_s3_bucket_name
    region         = data.aws_region.current.name
    retention_days = var.retention_days
  })

  # Conteúdo do script de entrypoint (gerado a partir do template)
  loki_entrypoint_script = templatefile("${path.module}/templates/loki-entrypoint.sh.tpl", {
    loki_config = local.loki_config_yaml
  })

  loki_container_definitions = jsonencode([
    {
      name      = "loki"
      image     = var.loki_image
      essential = true

      # IMPORTANTE: sobrescreve o ENTRYPOINT padrão da imagem do Loki
      entryPoint = ["/bin/sh", "-c"]
      command    = [local.loki_entrypoint_script]

      portMappings = [
        {
          containerPort = var.loki_port
          hostPort      = var.loki_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.loki.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "loki"
        }
      }

      environment = [
        {
          name  = "LOKI_ENV"
          value = "ecs"
        }
      ]
    }
  ])
}

# ---------------------------------------------------------------------------
# ECS Task Definition
# ---------------------------------------------------------------------------

resource "aws_ecs_task_definition" "loki" {
  family                   = local.base_name
  cpu                      = var.loki_cpu
  memory                   = var.loki_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = local.loki_container_definitions

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

# ---------------------------------------------------------------------------
# NLB + Target Group + Listener
# ---------------------------------------------------------------------------

resource "aws_lb" "loki" {
  name               = substr("${local.base_name}-nlb", 0, 32)
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_lb_target_group" "loki" {
  name        = substr("${local.base_name}-tg", 0, 32)
  port        = var.loki_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "HTTP"
    port                = var.loki_port
    path                = "/ready"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })
}

resource "aws_lb_listener" "loki" {
  load_balancer_arn = aws_lb.loki.arn
  port              = var.loki_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loki.arn
  }
}

# ---------------------------------------------------------------------------
# VPC Endpoint Service (PrivateLink) para Loki
# ---------------------------------------------------------------------------

resource "aws_vpc_endpoint_service" "loki" {
  # Serviço PrivateLink que expõe o NLB interno do Loki
  acceptance_required        = true
  network_load_balancer_arns = [aws_lb.loki.arn]

  # Contas que podem criar endpoints diretamente (ex: arn:aws:iam::<acc>:root)
  allowed_principals = var.vpc_endpoint_allowed_principals

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-endpoint-service"
  })
}

# ---------------------------------------------------------------------------
# ECS Service
# ---------------------------------------------------------------------------

resource "aws_ecs_service" "loki" {
  name            = local.base_name
  cluster         = aws_ecs_cluster.loki.arn
  task_definition = aws_ecs_task_definition.loki.arn
  desired_count   = var.loki_desired_count

  launch_type = length(var.capacity_provider_strategies) == 0 ? "FARGATE" : null

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategies
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = try(capacity_provider_strategy.value.weight, null)
      base              = try(capacity_provider_strategy.value.base, null)
    }
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.loki_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.loki.arn
    container_name   = "loki"
    container_port   = var.loki_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  enable_execute_command = false

  tags = merge(local.common_tags, {
    Name = "grafana-loki-${var.environment}"
  })

  lifecycle {
    ignore_changes = [desired_count]
  }
}
