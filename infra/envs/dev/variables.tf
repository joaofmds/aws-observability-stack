variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "project_name" {
  type        = string
  description = "Nome do projeto para prefixar recursos."
}

variable "owner" {
  description = "Time responsável pelo recurso"
  type        = string
}

variable "application" {
  description = "Aplicação que utiliza o recurso"
  type        = string
}

variable "region" {
  description = "Região AWS onde o sink OAM está localizado"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags padrão aplicadas aos recursos"
  default = {
    ManagedBy = "Terraform"
  }
}

variable "enable_loki" {
  description = "Se true, habilita o deployment do Loki no ECS"
  type        = bool
  default     = true
}

variable "alerts_sns_topic_arn" {
  description = "ARN do tópico SNS para alertas (opcional)"
  type        = string
  default     = null
}

variable "loki_vpc_endpoint_allowed_principals" {
  description = "Lista de principals IAM (ARNs) que podem criar VPC Endpoints (PrivateLink) para o Loki"
  type        = list(string)
  default = [
    "arn:aws:iam::940482420564:root",
    "arn:aws:iam::361769578479:root"
  ]
}

# ------------------------------------------------------------------------------
# ECS Deploy variables
# ------------------------------------------------------------------------------
variable "alb_listener_arn" {
  description = "ARN do listener do ALB para criar a regra de encaminhamento."
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group do ALB que deverá acessar o ECS."
  type        = string
}

variable "allowed_security_group_ids" {
  description = "Security Groups adicionais autorizados a falar com o ECS."
  type        = list(string)
  default     = []
}

variable "alb_priority" {
  description = "Prioridade da regra do ALB."
  type        = number
  default     = 100
}

variable "alb_path_patterns" {
  description = "Lista de paths que ativam a regra do ALB."
  type        = list(string)
  default     = ["/*"]
}

variable "alb_host_headers" {
  description = "Lista de host headers opcional."
  type        = list(string)
  default     = []
}

variable "container_port" {
  description = "Porta exposta pelo container."
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Número de tasks ECS desejadas."
  type        = number
  default     = 1
}

variable "capacity_provider_strategy" {
  description = "Estratégia de capacity providers."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number)
  }))
  default = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  ]
}

variable "task_cpu" {
  description = "CPU total da task ECS."
  type        = number
  default     = 512
}

variable "task_memory" {
  description = "Memória total da task ECS (MiB)."
  type        = number
  default     = 1024
}

variable "container_cpu" {
  description = "CPU do container principal."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memória do container principal (MiB)."
  type        = number
  default     = 512
}

variable "ecs_execution_role_arn" {
  description = "ARN da ECS Execution Role usada para pull da imagem."
  type        = string
}

variable "enable_autoscaling" {
  description = "Habilita Auto Scaling do ECS Service."
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  type    = number
  default = 1
}

variable "autoscaling_max_capacity" {
  type    = number
  default = 2
}

variable "autoscaling_cpu_target_value" {
  type    = number
  default = null
}

variable "autoscaling_requests_target_value" {
  type    = number
  default = null
}

variable "load_balancer_arn_suffix" {
  description = "Sufixo do ARN do ALB (para métricas)."
  type        = string
  default     = null
}

variable "autoscaling_scale_in_cooldown" {
  type    = number
  default = 300
}

variable "autoscaling_scale_out_cooldown" {
  type    = number
  default = 60
}

variable "enable_firelens" {
  description = "Habilita FireLens para roteamento de logs."
  type        = bool
  default     = true
}

variable "s3_logs_bucket_name" {
  description = "Bucket S3 de logs (quando FireLens habilitado)."
  type        = string
}

variable "s3_logs_prefix" {
  type    = string
  default = "apps"
}

variable "s3_logs_storage_class" {
  type    = string
  default = "STANDARD_IA"
}

variable "s3_logs_force_destroy" {
  type    = bool
  default = false
}

variable "s3_logs_transition_to_ia_days" {
  type    = number
  default = 30
}

variable "s3_logs_transition_to_glacier_days" {
  type    = number
  default = 90
}

variable "s3_logs_expiration_days" {
  type    = number
  default = 365
}

variable "task_role_arn" {
  description = "ARN de uma task role existente (opcional). Se null, o módulo ECS cria."
  type        = string
  default     = null
}

variable "task_role_policy_json" {
  description = "Política customizada em JSON para anexar à task role criada pelo módulo."
  type        = string
  default     = null
}

variable "task_managed_policy_arns" {
  description = "Policies gerenciadas adicionais para a task role criada pelo módulo."
  type        = list(string)
  default     = []
}

variable "amp_workspace_arn" {
  description = "ARN do workspace AMP usado pelo ADOT remote write."
  type        = string
  default     = null
}

variable "adot_assume_role_principals" {
  description = "Principals que podem assumir a role de remote write criada pelo módulo ADOT."
  type        = list(string)
  default     = []
}
variable "create_secret" {
  type    = bool
  default = false
}

variable "secret_name_override" {
  type    = string
  default = null
}

variable "secret_description" {
  type    = string
  default = ""
}

variable "secret_string" {
  type      = string
  sensitive = true
  default   = null
}

variable "secret_kms_key_id" {
  type    = string
  default = null
}
