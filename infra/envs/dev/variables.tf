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
