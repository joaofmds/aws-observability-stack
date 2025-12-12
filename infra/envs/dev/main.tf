data "aws_caller_identity" "current" {}

# Remote state do módulo network que gerencia a VPC
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket         = "r10score-terraform-state-dev"
    key            = "network/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "r10score-terraform-state-dev-locks"
    encrypt        = true
  }
}

# Remote state do módulo observability em produção (Prometheus, Grafana)
data "terraform_remote_state" "observability_prod" {
  backend = "s3"

  config = {
    bucket         = "r10score-terraform-state-prod"
    key            = "observability/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true

    assume_role = {
      role_arn     = "arn:aws:iam::016433505192:role/observability-core-remote-state-cross-account-access-prod"
      session_name = "tfstate-access"
    }
  }
}

# Remote state do módulo observability em dev (Loki VPC Endpoint)
data "terraform_remote_state" "observability_dev" {
  backend = "s3"

  config = {
    bucket         = "r10score-terraform-state-dev"
    key            = "observability/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "r10score-terraform-state-dev-locks"
    encrypt        = true
  }
}

module "ecs_deploy" {
  source = "../../modules/ecs-deploy"

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
  tags         = var.tags

  region = var.region

  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.network.outputs.app_subnet_ids
  alb_sg_id      = var.create_alb ? null : var.alb_security_group_id
  allowed_sg_ids = var.allowed_security_group_ids

  create_alb                           = var.create_alb
  alb_subnet_ids                       = var.create_alb ? data.terraform_remote_state.network.outputs.public_subnet_ids : []
  alb_internal                         = var.alb_internal
  alb_allowed_cidr_blocks              = var.alb_allowed_cidr_blocks
  alb_enable_https                     = var.alb_enable_https
  alb_certificate_arn                  = var.alb_certificate_arn
  alb_ssl_policy                       = var.alb_ssl_policy
  alb_https_redirect                   = var.alb_https_redirect
  alb_enable_deletion_protection       = var.alb_enable_deletion_protection
  alb_enable_http2                     = var.alb_enable_http2
  alb_enable_cross_zone_load_balancing = var.alb_enable_cross_zone_load_balancing
  alb_idle_timeout                     = var.alb_idle_timeout
  alb_ip_address_type                  = var.alb_ip_address_type
  alb_access_logs_bucket               = var.alb_access_logs_bucket
  alb_access_logs_prefix               = var.alb_access_logs_prefix

  listener_arn  = var.create_alb ? null : var.alb_listener_arn
  alb_priority  = var.create_alb ? null : var.alb_priority
  path_patterns = var.alb_path_patterns
  host_headers  = var.alb_host_headers

  create_cluster = true
  cluster_id     = null
  cluster_name   = "${var.application}-cluster-${var.environment}"

  container_port             = var.container_port
  desired_count              = var.desired_count
  capacity_provider_strategy = var.capacity_provider_strategy
  assign_public_ip           = false

  task_cpu         = var.task_cpu
  task_memory      = var.task_memory
  container_cpu    = var.container_cpu
  container_memory = var.container_memory

  enable_autoscaling                = var.enable_autoscaling
  autoscaling_min_capacity          = var.autoscaling_min_capacity
  autoscaling_max_capacity          = var.autoscaling_max_capacity
  autoscaling_cpu_target_value      = var.autoscaling_cpu_target_value
  autoscaling_requests_target_value = var.autoscaling_requests_target_value
  load_balancer_arn_suffix          = var.load_balancer_arn_suffix
  autoscaling_scale_in_cooldown     = var.autoscaling_scale_in_cooldown
  autoscaling_scale_out_cooldown    = var.autoscaling_scale_out_cooldown

  enable_cloudwatch_logs             = true
  enable_firelens                    = var.enable_firelens
  s3_logs_bucket_name                = var.s3_logs_bucket_name
  s3_logs_prefix                     = var.s3_logs_prefix
  s3_logs_storage_class              = var.s3_logs_storage_class
  s3_logs_force_destroy              = var.s3_logs_force_destroy
  s3_logs_transition_to_ia_days      = var.s3_logs_transition_to_ia_days
  s3_logs_transition_to_glacier_days = var.s3_logs_transition_to_glacier_days
  s3_logs_expiration_days            = var.s3_logs_expiration_days

  enable_metrics       = true
  amp_remote_write_url = data.terraform_remote_state.observability_prod.outputs.prometheus_remote_write_endpoint
  amp_workspace_arn    = data.terraform_remote_state.observability_prod.outputs.prometheus_workspace_arn

  enable_loki            = var.enable_loki
  loki_host              = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_dns_name : null
  loki_port              = var.enable_loki ? 3100 : null
  loki_security_group_id = var.enable_loki ? data.terraform_remote_state.observability_dev.outputs.loki_vpce_security_group_id : null

  create_secret        = var.create_secret
  secret_name_override = var.secret_name_override
  secret_description   = var.secret_description
  secret_string        = var.secret_string
  secret_kms_key_id    = var.secret_kms_key_id
}

resource "aws_security_group_rule" "loki_ingress_from_ecs" {
  count = var.enable_loki ? 1 : 0

  type                     = "ingress"
  from_port                = 3100
  to_port                  = 3100
  protocol                 = "tcp"
  source_security_group_id = module.ecs_deploy.ecs_sg_id
  security_group_id        = data.terraform_remote_state.observability_dev.outputs.loki_vpce_security_group_id
  description              = "Allow ECS Security Group to access Loki via VPC Endpoint (PrivateLink)"

  depends_on = [
    data.terraform_remote_state.observability_dev,
    module.ecs_deploy
  ]

  lifecycle {
    create_before_destroy = true
  }
}
