environment  = "dev"
project_name = "observability-core"
owner        = "DevOps Team"
application  = "observability-core"
region       = "us-east-1"

# ALB Configuration
create_alb                           = true
alb_internal                         = false
alb_allowed_cidr_blocks              = []
alb_enable_https                     = false
alb_certificate_arn                  = null
alb_ssl_policy                       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
alb_https_redirect                   = true
alb_enable_deletion_protection       = false
alb_enable_http2                     = true
alb_enable_cross_zone_load_balancing = true
alb_idle_timeout                     = 60
alb_ip_address_type                  = "ipv4"
alb_access_logs_bucket               = null
alb_access_logs_prefix               = null

# ALB Listener Rule (only used if create_alb = false)
alb_listener_arn      = null
alb_security_group_id = null
alb_priority          = 100
alb_path_patterns     = ["/*"]
alb_host_headers      = []

allowed_security_group_ids = []

container_port = 3000
desired_count  = 1

capacity_provider_strategy = [
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
]

task_cpu         = 512
task_memory      = 1024
container_cpu    = 256
container_memory = 512

enable_autoscaling                = false
autoscaling_min_capacity          = 1
autoscaling_max_capacity          = 2
autoscaling_cpu_target_value      = null
autoscaling_requests_target_value = null
load_balancer_arn_suffix          = null
autoscaling_scale_in_cooldown     = 300
autoscaling_scale_out_cooldown    = 60

enable_firelens                    = true
s3_logs_bucket_name                = "dev-firelens-logs-bucket"
s3_logs_prefix                     = "apps"
s3_logs_storage_class              = "STANDARD_IA"
s3_logs_force_destroy              = false
s3_logs_transition_to_ia_days      = 30
s3_logs_transition_to_glacier_days = 90
s3_logs_expiration_days            = 365

create_secret        = false
secret_name_override = null
secret_description   = ""
secret_string        = null
secret_kms_key_id    = null

task_role_arn               = null
task_role_policy_json       = null
task_managed_policy_arns    = []
amp_workspace_arn           = null
adot_assume_role_principals = []