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
