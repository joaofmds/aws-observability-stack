# =============================================================================
# TAGS
# =============================================================================
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

variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "Terraform"
  }
  description = "Tags padrão aplicadas aos recursos"
}

# =============================================================================
# COMMON
# =============================================================================
variable "region" {
  description = "AWS region"
  type        = string
}

# =============================================================================
# AMAZON MANAGED PROMETHEUS (AMP)
# =============================================================================
variable "prometheus_alias" {
  description = "Alias legível para o Workspace do AMP"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,100}$", var.prometheus_alias))
    error_message = "Alias deve conter apenas letras, números, hífen e underscore (até 100 caracteres)."
  }
}

# =============================================================================
# AMAZON MANAGED GRAFANA
# =============================================================================
variable "grafana_enabled_data_sources" {
  description = "Lista de fontes de dados a habilitar no Grafana"
  type        = list(string)
  default     = ["CLOUDWATCH", "XRAY"]
}

variable "grafana_authentication_providers" {
  description = "Lista de provedores de autenticação (ex: AWS_SSO)"
  type        = list(string)
  default     = ["AWS_SSO"]
}

variable "grafana_account_access_type" {
  description = "Tipo de acesso à conta (CURRENT_ACCOUNT ou ORGANIZATION)"
  type        = string
  default     = "CURRENT_ACCOUNT"
}

variable "grafana_alerting_enabled" {
  description = "Se true, habilita o sistema de alertas unificado do Grafana."
  type        = bool
  default     = true
}

variable "grafana_enable_plugin_management" {
  description = "Se true, permite que administradores do Grafana gerenciem plugins."
  type        = bool
  default     = true
}

variable "grafana_name_prefix" {
  description = "Prefixo opcional para compor o nome do workspace Grafana"
  type        = string
  default     = null
}

variable "grafana_vpc_id" {
  description = "ID da VPC onde o workspace Grafana terá ENIs para acessar datasources privados. Se null, o workspace não terá vpc_configuration."
  type        = string
  default     = null
}

variable "grafana_vpc_subnet_ids" {
  description = "Subnets da VPC onde o workspace Grafana criará ENIs. Usado quando grafana_vpc_id não é null."
  type        = list(string)
  default     = []
}

variable "grafana_custom_policy_json" {
  description = "Política IAM customizada (JSON) para o Grafana. Se null, serão usadas apenas as managed policies."
  type        = string
  default     = null
}

variable "grafana_managed_policy_arns" {
  description = <<EOF
Lista de ARNs de políticas gerenciadas para anexar à role do Grafana.
Políticas recomendadas por datasource:
- CLOUDWATCH: CloudWatchReadOnlyAccess
- XRAY: AWSXRayReadOnlyAccess
- PROMETHEUS: AmazonPrometheusReadOnlyAccess
- LOKI: (geralmente não precisa de política, acessa via VPC/PrivateLink)
EOF
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSXRayReadOnlyAccess"
  ]
}

# =============================================================================
# LOKI ON ECS
# =============================================================================
variable "enable_loki" {
  description = "Se true, habilita o deployment do Loki no ECS"
  type        = bool
  default     = false
}

variable "loki_name_prefix" {
  description = "Prefixo para nomear recursos do Loki (ex: observability-o11y)"
  type        = string
  default     = "observability-o11y"
}

variable "loki_vpc_id" {
  description = "ID da VPC onde o Loki será executado"
  type        = string
  default     = null
  validation {
    condition     = var.enable_loki == false || (var.enable_loki && var.loki_vpc_id != null)
    error_message = "Quando enable_loki=true, loki_vpc_id deve ser informado."
  }
}

variable "loki_private_subnet_ids" {
  description = "Lista de subnets privadas para o serviço ECS Fargate do Loki"
  type        = list(string)
  default     = []
  validation {
    condition     = var.enable_loki == false || (var.enable_loki && length(var.loki_private_subnet_ids) > 0)
    error_message = "Quando enable_loki=true, loki_private_subnet_ids deve conter pelo menos uma subnet."
  }
}

variable "loki_ecs_cluster_name" {
  description = "Nome do cluster ECS que será criado para o Loki. Se nulo, será derivado de loki_name_prefix."
  type        = string
  default     = null
}

variable "loki_create_s3_bucket" {
  description = "Se true, cria o bucket S3 para armazenamento do Loki. Se false, usa loki_s3_bucket_name existente."
  type        = bool
  default     = true
}

variable "loki_s3_bucket_name" {
  description = "Nome do bucket S3 para Loki. Obrigatório se loki_create_s3_bucket = false. Se loki_create_s3_bucket = true e não informado, será gerado."
  type        = string
  default     = null

  validation {
    condition     = var.enable_loki == false || var.loki_create_s3_bucket == true || (var.loki_create_s3_bucket == false && var.loki_s3_bucket_name != null)
    error_message = "Quando loki_create_s3_bucket é false, loki_s3_bucket_name deve ser informado."
  }
}

variable "loki_s3_bucket_kms_key_arn" {
  description = "ARN da chave KMS para criptografia do bucket S3 do Loki. Se null, usa AES256."
  type        = string
  default     = null
}

variable "loki_image" {
  description = "Imagem Docker do Loki"
  type        = string
  default     = "grafana/loki:3.1.0"
}

variable "loki_cpu" {
  description = "CPU da task Fargate do Loki (em unidades da AWS, ex: 256, 512, 1024)"
  type        = number
  default     = 1024
}

variable "loki_memory" {
  description = "Memória da task Fargate do Loki (em MiB, ex: 512, 1024, 2048)"
  type        = number
  default     = 2048
}

variable "loki_desired_count" {
  description = "Número de tasks desejadas para o serviço Loki"
  type        = number
  default     = 1
}

variable "loki_port" {
  description = "Porta HTTP do Loki"
  type        = number
  default     = 3100
}

variable "loki_retention_days" {
  description = "Período de retenção de logs no Loki (em dias)"
  type        = number
  default     = 30
}

variable "loki_allowed_cidr_blocks" {
  description = "CIDRs permitidos para acessar o Loki via NLB. Ex: VPCs de dev/prd ou ranges da org."
  type        = list(string)
  default     = []
}

variable "loki_allowed_security_group_ids" {
  description = "Security groups permitidos para acessar o Loki (usado em ingress rule baseada em SG)."
  type        = list(string)
  default     = []
}

variable "loki_capacity_provider_strategies" {
  description = <<EOF
Lista de estratégias de capacity provider para o serviço ECS do Loki.
Se vazio, o serviço usará launch_type = FARGATE.
Exemplo:
[
  {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  },
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 3
  }
]
EOF
  type = list(object({
    capacity_provider = string
    weight            = optional(number)
    base              = optional(number)
  }))
  default = []
}

variable "loki_cloudwatch_log_retention_days" {
  description = "Retenção, em dias, do log group do Loki no CloudWatch"
  type        = number
  default     = 30
}

variable "loki_vpc_endpoint_allowed_principals" {
  description = <<EOF
Lista de principals IAM (ARNs) que podem criar VPC Endpoints (PrivateLink) para o Loki.
Exemplo: ["arn:aws:iam::940482420564:root", "arn:aws:iam::<prod-account-id>:root"]
EOF
  type        = list(string)
  default     = []
}

