# Módulo VPC

Módulo Terraform completo para criação de VPC na AWS com suporte a múltiplas Availability Zones, subnets públicas e privadas, NAT Gateways, VPC Endpoints, Flow Logs e muito mais.

## Características

- ✅ VPC configurável com suporte a IPv4 e IPv6
- ✅ Subnets públicas, privadas e de banco de dados em múltiplas AZs
- ✅ Internet Gateway configurável
- ✅ NAT Gateways com opção de single ou múltiplos (um por AZ)
- ✅ Route Tables configuráveis
- ✅ VPC Endpoints para S3, DynamoDB e outros serviços
- ✅ VPC Flow Logs (CloudWatch Logs ou S3)
- ✅ DHCP Options Set
- ✅ Security Groups padrão configuráveis
- ✅ Tags consistentes em todos os recursos
- ✅ Outputs completos para integração com outros módulos

## Uso Básico

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment  = "dev"
  project_name = "my-project"
  owner        = "DevOps Team"
  application  = "infrastructure"

  vpc_cidr         = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_nat_gateway = true
  single_nat_gateway = false  # Um NAT Gateway por AZ (mais resiliente)
  
  enable_database_subnets = true
  enable_vpc_endpoints    = true
  vpc_endpoints           = ["s3", "dynamodb", "ec2", "ecr.api", "ecr.dkr"]
  
  enable_flow_log = true
  flow_log_destination_type = "cloud-watch-logs"

  tags = {
    ManagedBy = "Terraform"
    CostCenter = "Infrastructure"
  }
}
```

## Uso Avançado

```hcl
module "vpc" {
  source = "../../modules/vpc"

  environment  = "prod"
  project_name = "production"
  owner        = "Platform Team"
  application  = "infrastructure"

  # VPC Configuration
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT Gateway Configuration
  enable_nat_gateway = true
  single_nat_gateway = false  # Alta disponibilidade: um NAT por AZ

  # Subnets Configuration
  enable_database_subnets = true
  map_public_ip_on_launch = true

  # VPC Endpoints
  enable_vpc_endpoints = true
  vpc_endpoints = [
    "s3",
    "dynamodb",
    "ec2",
    "ecr.api",
    "ecr.dkr",
    "logs",
    "sts",
    "secretsmanager"
  ]

  # Flow Logs
  enable_flow_log              = true
  flow_log_destination_type    = "s3"
  flow_log_log_destination     = "arn:aws:s3:::my-vpc-flow-logs-bucket/"
  flow_log_traffic_type        = "ALL"

  # DHCP Options
  enable_dhcp_options              = true
  dhcp_options_domain_name         = "example.com"
  dhcp_options_domain_name_servers = ["10.0.0.2", "10.0.0.3"]

  # Security Groups
  create_default_security_groups = true
  default_security_group_name    = "default"
  default_security_group_ingress = [
    {
      description = "Allow SSH from management subnet"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/24"]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "Terraform"
    CostCenter  = "Infrastructure"
  }
}
```

## Exemplos de Configuração

### VPC Econômica (Single NAT Gateway)

```hcl
module "vpc_dev" {
  source = "../../modules/vpc"

  environment  = "dev"
  project_name = "my-project"
  owner        = "DevOps"

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Economiza custos em dev

  enable_flow_log = false  # Desabilita flow logs em dev
}
```

### VPC de Produção (Alta Disponibilidade)

```hcl
module "vpc_prod" {
  source = "../../modules/vpc"

  environment  = "prod"
  project_name = "production"
  owner        = "Platform Team"

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_nat_gateway = true
  single_nat_gateway = false  # Um NAT por AZ para HA

  enable_database_subnets = true
  enable_vpc_endpoints    = true
  vpc_endpoints           = ["s3", "dynamodb"]

  enable_flow_log              = true
  flow_log_destination_type    = "s3"
  flow_log_log_destination     = "arn:aws:s3:::prod-vpc-flow-logs/"

  tags = {
    Environment = "production"
    Backup      = "required"
  }
}
```

## Variáveis

### Principais

| Nome | Descrição | Tipo | Padrão |
|------|-----------|------|--------|
| `environment` | Ambiente de implantação | `string` | - |
| `project_name` | Nome do projeto | `string` | - |
| `vpc_cidr` | CIDR block da VPC | `string` | `"10.0.0.0/16"` |
| `availability_zones` | Lista de AZs | `list(string)` | `[]` |
| `enable_nat_gateway` | Habilitar NAT Gateways | `bool` | `true` |
| `single_nat_gateway` | Usar apenas um NAT Gateway | `bool` | `false` |

Veja `variables.tf` para a lista completa de variáveis.

## Outputs

### Principais

| Nome | Descrição |
|------|-----------|
| `vpc_id` | ID da VPC |
| `public_subnet_ids` | IDs das subnets públicas |
| `private_subnet_ids` | IDs das subnets privadas |
| `database_subnet_ids` | IDs das subnets de banco de dados |
| `nat_gateway_ids` | IDs dos NAT Gateways |
| `internet_gateway_id` | ID do Internet Gateway |

Veja `outputs.tf` para a lista completa de outputs.

## Requisitos

- Terraform >= 1.0
- AWS Provider >= 5.0

## Observações

- As subnets são criadas automaticamente baseadas no `vpc_cidr` e número de AZs
- O módulo calcula automaticamente os CIDR blocks das subnets
- Por padrão, cria Route Tables separadas para subnets públicas, privadas e de banco de dados
- VPC Endpoints são criados apenas se `enable_vpc_endpoints = true`
- Flow Logs requerem IAM Role quando usando CloudWatch Logs

## Autor

Criado como parte do projeto de observabilidade.

