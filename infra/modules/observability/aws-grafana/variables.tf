variable "enabled_data_sources" {
  description = "Lista de fontes de dados a habilitar no Grafana"
  type        = list(string)
  default     = ["CLOUDWATCH", "XRAY"]
}

variable "grafana_service_role_arn" {
  description = "ARN da IAM Role para o Grafana acessar os serviços"
  type        = string
}

variable "authentication_providers" {
  description = "Lista de provedores de autenticação (ex: AWS_SSO)"
  type        = list(string)
  default     = ["AWS_SSO"]
}

variable "account_access_type" {
  description = "Tipo de acesso à conta (CURRENT_ACCOUNT ou ORGANIZATION)"
  type        = string
  default     = "CURRENT_ACCOUNT"
}

variable "grafana_alerting_enabled" {
  description = "Se true, habilita o sistema de alertas unificado do Grafana."
  type        = bool
  default     = true
}

variable "enable_plugin_management" {
  description = "Se true, permite que administradores do Grafana gerenciem plugins."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Ambiente de implantação"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "application" {
  description = "Aplicação que utiliza o recurso"
  type        = string
}

variable "owner" {
  description = "Responsável pelo recurso"
  type        = string
}

variable "tags" {
  description = "Tags customizadas"
  type        = map(string)
  default     = { ManagedBy = "Terraform" }
}

variable "name_prefix" {
  description = "Prefixo opcional para compor o nome do workspace"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID da VPC onde o workspace Grafana terá ENIs para acessar datasources privados. Se null, o workspace não terá vpc_configuration."
  type        = string
  default     = null
}

variable "vpc_subnet_ids" {
  description = "Subnets da VPC onde o workspace Grafana criará ENIs. Usado quando vpc_id não é null."
  type        = list(string)
  default     = []
}
