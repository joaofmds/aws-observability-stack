variable "name_prefix" {
  description = "Prefixo para nomear recursos (ex: observability-o11y)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o Loki será executado"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para o serviço ECS Fargate"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS que será criado para o Loki. Se nulo, será derivado de name_prefix."
  type        = string
  default     = null
}

variable "create_s3_bucket" {
  description = "Se true, cria o bucket S3 para armazenamento do Loki. Se false, usa s3_bucket_name existente."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para Loki. Obrigatório se create_s3_bucket = false. Se create_s3_bucket = true e não informado, será gerado."
  type        = string
  default     = null

  validation {
    condition     = !(var.create_s3_bucket == false && var.s3_bucket_name == null)
    error_message = "Quando create_s3_bucket é false, s3_bucket_name deve ser informado."
  }
}

variable "s3_bucket_kms_key_arn" {
  description = "ARN da chave KMS para criptografia do bucket S3. Se null, usa AES256."
  type        = string
  default     = null
}

variable "loki_image" {
  description = "Imagem Docker do Loki"
  type        = string
  default     = "grafana/loki:3.1.0"
}

variable "loki_cpu" {
  description = "CPU da task Fargate (em unidades da AWS, ex: 256, 512, 1024)"
  type        = number
  default     = 1024
}

variable "loki_memory" {
  description = "Memória da task Fargate (em MiB, ex: 512, 1024, 2048)"
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

variable "retention_days" {
  description = "Período de retenção de logs no Loki (em dias)"
  type        = number
  default     = 30
}

variable "allowed_cidr_blocks" {
  description = "CIDRs permitidos para acessar o Loki via NLB. Ex: VPCs de dev/prd ou ranges da org."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Security groups permitidos para acessar o Loki (usado em ingress rule baseada em SG)."
  type        = list(string)
  default     = []
}

variable "capacity_provider_strategies" {
  description = <<EOF
Lista de estratégias de capacity provider para o serviço ECS.
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

variable "cloudwatch_log_retention_days" {
  description = "Retenção, em dias, do log group do Loki no CloudWatch"
  type        = number
  default     = 30
}

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

variable "vpc_endpoint_allowed_principals" {
  description = <<EOF
Lista de principals IAM (ARNs) que podem criar VPC Endpoints (PrivateLink) para o Loki.
Exemplo: ["arn:aws:iam::940482420564:root", "arn:aws:iam::<prod-account-id>:root"]
EOF
  type        = list(string)
  default     = []
}
