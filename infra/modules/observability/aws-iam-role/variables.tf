variable "role_name" {
  description = "Nome da IAM Role"
  type        = string
}

variable "policy_name" {
  description = "Nome da IAM Policy"
  type        = string
}

variable "role_description" {
  description = "Descrição da IAM Role"
  type        = string
  default     = null
}

variable "assume_role_policy_json" {
  description = "Política de confiança (JSON) para a IAM Role"
  type        = string
}

variable "policy_json" {
  description = "Política IAM (JSON) a ser anexada à role"
  type        = string
  default     = null
}

variable "policy_description" {
  description = "Descrição da política IAM"
  type        = string
  default     = null
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

variable "name_prefix" {
  description = "Prefixo para compor o nome da role e policy"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Lista de ARNs de políticas gerenciadas para anexar à role"
  type        = list(string)
  default     = []
}

variable "prevent_destroy" {
  description = "Se true, protege a role/policy de destruição acidental"
  type        = bool
  default     = true
}