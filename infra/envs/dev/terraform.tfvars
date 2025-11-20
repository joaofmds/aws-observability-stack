environment  = "o11y"
project_name = "observability-core"
owner        = "DevOps Team"
application  = "observability-core"
region       = "us-east-1"

alb_listener_arn           = "arn:aws:elasticloadbalancing:us-east-1:625997627087:loadbalancer/app/app-loki-alb/c3107481bf98168a"
alb_security_group_id      = "sg-0f472123ba22ec1a1"
allowed_security_group_ids = []
alb_priority               = 100
alb_path_patterns          = ["/"]
alb_host_headers           = []

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

ecs_execution_role_arn = "arn:aws:iam::123456789012:role/dev-ecs-execution-role"

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