variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto para prefixar recursos"
  type        = string
}

variable "owner" {
  description = "Time ou pessoa responsável pelo recurso"
  type        = string
}

variable "application" {
  description = "Nome da aplicação"
  type        = string
  default     = "infrastructure"
}

variable "tags" {
  description = "Tags adicionais a serem aplicadas aos recursos"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC (ex: 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "O vpc_cidr deve ser um CIDR válido."
  }
}

variable "availability_zones" {
  description = "Lista de Availability Zones onde criar as subnets"
  type        = list(string)
  default     = []
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar suporte DNS na VPC"
  type        = bool
  default     = true
}


variable "assign_generated_ipv6_cidr_block" {
  description = "Solicitar um bloco CIDR IPv6 gerado pela AWS"
  type        = bool
  default     = false
}

variable "enable_internet_gateway" {
  description = "Habilitar criação do Internet Gateway"
  type        = bool
  default     = true
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

variable "enable_nat_instance" {
  description = "Usar instância NAT em vez de NAT Gateway (não recomendado para produção)"
  type        = bool
  default     = false
}

variable "nat_eip_tags" {
  description = "Tags adicionais para os Elastic IPs dos NAT Gateways"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Tags adicionais para os NAT Gateways"
  type        = map(string)
  default     = {}
}

variable "enable_database_subnets" {
  description = "Criar subnets dedicadas para bancos de dados (isoladas)"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Mapear IP público automaticamente nas subnets públicas"
  type        = bool
  default     = true
}

variable "public_subnet_tags" {
  description = "Tags adicionais para subnets públicas"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Tags adicionais para subnets privadas"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Tags adicionais para subnets de banco de dados"
  type        = map(string)
  default     = {}
}

variable "create_public_route_table" {
  description = "Criar Route Table separada para subnets públicas"
  type        = bool
  default     = true
}

variable "create_private_route_table" {
  description = "Criar Route Tables separadas para cada subnet privada"
  type        = bool
  default     = true
}

variable "create_database_route_table" {
  description = "Criar Route Table para subnets de banco de dados"
  type        = bool
  default     = true
}

variable "public_route_table_tags" {
  description = "Tags adicionais para a Route Table pública"
  type        = map(string)
  default     = {}
}

variable "private_route_table_tags" {
  description = "Tags adicionais para as Route Tables privadas"
  type        = map(string)
  default     = {}
}

variable "database_route_table_tags" {
  description = "Tags adicionais para a Route Table de banco de dados"
  type        = map(string)
  default     = {}
}

variable "enable_vpc_endpoints" {
  description = "Habilitar criação de VPC Endpoints"
  type        = bool
  default     = false
}

variable "vpc_endpoints" {
  description = "Lista de serviços AWS para criar VPC Endpoints"
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "vpc_endpoint_route_table_ids" {
  description = "IDs das Route Tables para associar aos VPC Endpoints"
  type        = list(string)
  default     = []
}

variable "enable_flow_log" {
  description = "Habilitar VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_log_traffic_type" {
  description = "Tipo de tráfego para registrar (ALL, ACCEPT, REJECT)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.flow_log_traffic_type)
    error_message = "O flow_log_traffic_type deve ser ALL, ACCEPT ou REJECT."
  }
}

variable "flow_log_destination_type" {
  description = "Destino dos Flow Logs (cloud-watch-logs, s3)"
  type        = string
  default     = "cloud-watch-logs"
  validation {
    condition     = contains(["cloud-watch-logs", "s3"], var.flow_log_destination_type)
    error_message = "O flow_log_destination_type deve ser cloud-watch-logs ou s3."
  }
}

variable "flow_log_log_destination" {
  description = "ARN do destino dos Flow Logs (CloudWatch Log Group ou S3 bucket)"
  type        = string
  default     = null
}

variable "flow_log_iam_role_arn" {
  description = "ARN da IAM Role para Flow Logs (requerido para CloudWatch Logs)"
  type        = string
  default     = null
}

variable "enable_dhcp_options" {
  description = "Habilitar configuração de DHCP Options"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Nome de domínio para DHCP Options"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Servidores DNS para DHCP Options"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Servidores NTP para DHCP Options"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Servidores NetBIOS para DHCP Options"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Tipo de nó NetBIOS para DHCP Options"
  type        = string
  default     = null
}

variable "create_default_security_groups" {
  description = "Criar Security Groups padrão (default, public, private)"
  type        = bool
  default     = false
}

variable "default_security_group_name" {
  description = "Nome do Security Group padrão"
  type        = string
  default     = "default"
}

variable "default_security_group_description" {
  description = "Descrição do Security Group padrão"
  type        = string
  default     = "Default security group for VPC"
}

variable "default_security_group_ingress" {
  description = "Regras de ingress para o Security Group padrão"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "default_security_group_egress" {
  description = "Regras de egress para o Security Group padrão"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

