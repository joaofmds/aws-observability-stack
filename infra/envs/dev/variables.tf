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

variable "create_alb" {
  description = "Se true, cria o Application Load Balancer completo. Se false, apenas cria listener rule em ALB existente"
  type        = bool
  default     = true
}

variable "alb_internal" {
  description = "Se true, cria um ALB interno. Se false, cria um ALB público"
  type        = bool
  default     = false
}

variable "alb_allowed_cidr_blocks" {
  description = "Lista de blocos CIDR permitidos para acessar o ALB (usado apenas se alb_internal=true)"
  type        = list(string)
  default     = []
}

variable "alb_enable_https" {
  description = "Se true, habilita o listener HTTPS no ALB"
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "ARN do certificado SSL/TLS para o listener HTTPS"
  type        = string
  default     = null
}

variable "alb_ssl_policy" {
  description = "Política SSL a ser usada no listener HTTPS"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "alb_https_redirect" {
  description = "Se true, redireciona HTTP para HTTPS automaticamente"
  type        = bool
  default     = true
}

variable "alb_enable_deletion_protection" {
  description = "Se true, protege o ALB contra exclusão acidental"
  type        = bool
  default     = false
}

variable "alb_enable_http2" {
  description = "Se true, habilita HTTP/2 no ALB"
  type        = bool
  default     = true
}

variable "alb_enable_cross_zone_load_balancing" {
  description = "Se true, habilita cross-zone load balancing"
  type        = bool
  default     = true
}

variable "alb_idle_timeout" {
  description = "Tempo limite de inatividade (em segundos) antes de fechar a conexão"
  type        = number
  default     = 60
}

variable "alb_ip_address_type" {
  description = "Tipo de endereço IP (ipv4 ou dualstack)"
  type        = string
  default     = "ipv4"
}

variable "alb_access_logs_bucket" {
  description = "Nome do bucket S3 para armazenar os access logs do ALB (opcional)"
  type        = string
  default     = null
}

variable "alb_access_logs_prefix" {
  description = "Prefixo para os access logs no bucket S3"
  type        = string
  default     = null
}

variable "alb_listener_arn" {
  description = "ARN do listener do ALB para criar a regra de encaminhamento (usado apenas se create_alb=false)"
  type        = string
  default     = null
}

variable "alb_security_group_id" {
  description = "Security Group do ALB que deverá acessar o ECS (usado apenas se create_alb=false)"
  type        = string
  default     = null
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

variable "vpc_cidr" {
  description = "CIDR block para a VPC (ex: 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Lista de Availability Zones onde criar as subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "enable_nat_gateway" {
  description = "Habilitar criação de NAT Gateways nas subnets públicas"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Se true, cria apenas um NAT Gateway na primeira AZ (reduz custos)"
  type        = bool
  default     = false
}

variable "enable_database_subnets" {
  description = "Criar subnets dedicadas para bancos de dados (isoladas)"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Habilitar criação de VPC Endpoints"
  type        = bool
  default     = false
}

variable "vpc_endpoints" {
  description = "Lista de serviços AWS para criar VPC Endpoints"
  type        = list(string)
  default     = []
}

variable "enable_flow_log" {
  description = "Habilitar VPC Flow Logs"
  type        = bool
  default     = false
}
