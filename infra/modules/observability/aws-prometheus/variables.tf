variable "alias" {
  description = "Alias legível para o Workspace do AMP"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,100}$", var.alias))
    error_message = "Alias deve conter apenas letras, números, hífen e underscore (até 100 caracteres)."
  }
}

variable "region" {
  description = "Região AWS"
  type        = string
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
