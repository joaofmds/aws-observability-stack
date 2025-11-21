# POC Observability - AWS

Prova de Conceito (POC) de uma stack completa de observabilidade na AWS, demonstrando a integração de logs, métricas e traces utilizando serviços gerenciados da AWS e ferramentas de observabilidade open-source.

## 📋 Visão Geral

Este projeto implementa uma arquitetura de observabilidade moderna e escalável, utilizando:

- **Amazon Managed Prometheus (AMP)** para métricas
- **Amazon Managed Grafana** para visualização unificada
- **Loki** (self-hosted no ECS) para agregação de logs
- **AWS Distro for OpenTelemetry (ADOT)** como coletor de telemetria
- **ECS Fargate** para execução de containers
- **Terraform** para Infraestrutura como Código (IaC)

## 🏗️ Arquitetura

### Componentes Principais

#### 1. Aplicação (`/app`)
Backend Node.js que gera logs sintéticos para testes de carga e observabilidade.

**Tecnologias:**
- Node.js + Express
- Pino (logger estruturado)

**Endpoints:**
- `GET /` - Health check
- `GET /start?rate=X` - Inicia geração de logs (padrão: 1000 logs/seg)
- `GET /stop` - Para a geração de logs
- `GET /status` - Status atual do gerador
- `GET /burst?count=X` - Gera burst único de logs

#### 2. Infraestrutura (`/infra`)

##### Módulo `ecs-deploy` - Deploy Completo de Aplicações ECS

Módulo Terraform modularizado que facilita o deploy de aplicações ECS com observabilidade integrada.

**Submódulos:**

- **`adot/`** - AWS Distro for OpenTelemetry Collector
  - Sidecar container que coleta métricas e traces
  - Recebe telemetria via OTLP (ports 4317/4318)
  - Envia métricas para AMP (Remote Write)
  - Configuração via template YAML

- **`ecs/`** - ECS Service e Task Definition
  - Container principal da aplicação
  - FireLens sidecar (opcional) para roteamento de logs
  - ADOT sidecar para coleta de telemetria
  - Auto Scaling configurável (CPU/requisições)
  - Integração com CloudWatch Logs e Loki

- **`alb/`** - Application Load Balancer
  - Target Group configurável
  - Listener Rules com path patterns
  - Health checks customizáveis

- **`ecr/`** - Elastic Container Registry
  - Repositório de imagens Docker
  - Lifecycle policies
  - Scanning de vulnerabilidades

- **`firelens/`** - FireLens/Fluent Bit Sidecar
  - Roteamento de logs para S3
  - Integração opcional com Loki
  - Bucket S3 com lifecycle policies
  - Permissões IAM configuradas

- **`iam/`** - IAM Roles e Policies
  - Task Role e Execution Role
  - Políticas customizadas
  - Anexo de managed policies

- **`secrets-manager/`** - AWS Secrets Manager
  - Armazenamento seguro de secrets
  - Integração com ECS

##### Módulos de Observabilidade (`/observability`)

- **`aws-prometheus/`** - Amazon Managed Service for Prometheus
  - Workspace centralizado para métricas
  - Remote Write endpoint para ADOT
  - Query endpoint para Grafana

- **`aws-loki-ecs/`** - Loki Self-Hosted no ECS
  - Deploy em ECS Fargate
  - Armazenamento no S3
  - Network Load Balancer interno
  - VPC Endpoint Service (PrivateLink) para acesso cross-account
  - Retenção configurável

- **`aws-grafana/`** - Amazon Managed Grafana
  - Workspace gerenciado
  - Data sources: CloudWatch e Prometheus
  - Autenticação via AWS SSO
  - IAM Role para acesso aos serviços AWS

## 🔄 Fluxo de Dados de Observabilidade

### Logs
```
Aplicação (Pino) → stdout/stderr
    ↓
CloudWatch Logs (awslogs driver)
    OU
FireLens (Fluent Bit) → S3
    OU
FireLens (Fluent Bit) → Loki
    ↓
Grafana (CloudWatch Logs Insights / Loki)
```

### Métricas
```
Aplicação (OTLP) 
    ↓
ADOT Collector (recebe OTLP)
    ↓
Amazon Managed Prometheus (Remote Write)
    ↓
Grafana (Prometheus Data Source)
```

## 🚀 Quick Start

### Pré-requisitos

- AWS CLI configurado
- Terraform >= 1.6.0
- Node.js >= 14.x
- Acesso às contas AWS configuradas

### Deploy da Infraestrutura

1. **Configure o backend remoto do Terraform:**

```bash
cd infra/envs/dev
terraform init
```

2. **Revise e ajuste as variáveis em `terraform.tfvars`**

3. **Aplique a infraestrutura:**

```bash
terraform plan
terraform apply
```

### Obter Endpoints da Aplicação

Após o deploy, use o script para listar todos os endpoints:

```bash
./scripts/get-endpoints.sh
```

Ou consulte diretamente os outputs do Terraform:

```bash
cd infra/envs/dev

# ALB DNS
terraform output alb_dns_name

# Grafana Workspace URL
terraform output grafana_workspace_url

# Loki Endpoint (interno VPC)
terraform output loki_endpoint_http

# Prometheus Endpoints
terraform output prometheus_query_endpoint
terraform output prometheus_remote_write_endpoint
```

### Testar Endpoints

#### Aplicação Principal (ALB)
```bash
# Health check
curl http://$(terraform output -raw alb_dns_name)/

# Iniciar geração de logs
curl http://$(terraform output -raw alb_dns_name)/start?rate=1000

# Status
curl http://$(terraform output -raw alb_dns_name)/status

# Parar geração
curl http://$(terraform output -raw alb_dns_name)/stop
```

#### Loki (dentro da VPC)
```bash
# Health check (requer acesso à VPC)
curl http://$(terraform output -raw loki_nlb_dns_name):3100/ready

# Query API
curl http://$(terraform output -raw loki_nlb_dns_name):3100/loki/api/v1/labels
```

**Nota**: O Loki é acessível apenas dentro da VPC. Para testar de fora, use uma instância EC2 na mesma VPC ou configure um bastion host.

#### Grafana
1. Acesse a URL retornada por `terraform output grafana_workspace_url`
2. Faça login via AWS SSO
3. Configure os data sources (Prometheus e CloudWatch Logs)

### Executar a Aplicação Localmente

1. **Instale as dependências:**

```bash
cd app
npm install
```

2. **Execute a aplicação:**

```bash
npm start
```

3. **Controle o gerador de logs:**

```bash
# Iniciar geração (1000 logs/seg)
curl "http://localhost:3000/start?rate=1000"

# Status
curl "http://localhost:3000/status"

# Burst de logs
curl "http://localhost:3000/burst?count=50000"

# Parar
curl "http://localhost:3000/stop"
```

## 📁 Estrutura do Projeto

```
.
├── app/                          # Aplicação Node.js
│   ├── app.js                   # Aplicação principal
│   ├── logger.js                # Configuração do logger Pino
│   ├── package.json             # Dependências Node.js
│   ├── Dockerfile               # Imagem Docker da aplicação
│   └── README.md                # Documentação da aplicação
│
├── infra/                        # Infraestrutura Terraform
│   ├── envs/                    # Ambientes (dev, staging, prod)
│   │   └── dev/
│   │       ├── backend.tf       # Configuração do backend Terraform
│   │       ├── main.tf          # Módulos principais
│   │       ├── variables.tf     # Variáveis do ambiente
│   │       ├── outputs.tf       # Outputs do ambiente
│   │       └── terraform.tfvars # Valores das variáveis
│   │
│   └── modules/                 # Módulos Terraform reutilizáveis
│       ├── vpc/                 # Módulo VPC
│       ├── ecs-deploy/          # Módulo completo de deploy ECS
│       │   ├── adot/            # Módulo ADOT
│       │   ├── alb/             # Módulo ALB
│       │   ├── ecr/             # Módulo ECR
│       │   ├── ecs/             # Módulo ECS
│       │   ├── firelens/        # Módulo FireLens
│       │   ├── secrets-manager/ # Módulo Secrets Manager
│       │   ├── variables.tf     # Variáveis do módulo
│       │   ├── versions.tf      # Versões dos providers
│       │   └── outputs.tf       # Outputs do módulo
│       │
│       └── observability/       # Módulos de observabilidade
│           ├── aws-grafana/     # Módulo Grafana
│           ├── aws-loki-ecs/    # Módulo Loki
│           ├── aws-prometheus/  # Módulo Prometheus
│           ├── aws-iam-role/    # Módulo IAM Role reutilizável
│           ├── main.tf          # Módulo principal de observabilidade
│           ├── variables.tf     # Variáveis do módulo
│           └── outputs.tf       # Outputs do módulo
│
├── scripts/                      # Scripts utilitários
│   └── get-endpoints.sh         # Script para listar endpoints
│
└── README.md                     # Este arquivo
```

## 🔐 Segurança

- **IAM Roles**: Cada recurso utiliza IAM roles específicas
- **Secrets Manager**: Secrets sensíveis armazenados de forma segura
- **VPC**: Recursos em subnets privadas quando possível
- **Encryption**: S3 buckets e secrets criptografados
- **Network Security**: Security Groups configurados para acesso mínimo necessário

## 🌐 Cross-Account

O projeto suporta acesso cross-account via:

- **IAM Roles**: AssumeRole entre contas AWS
- **VPC Endpoint Service**: PrivateLink para acesso ao Loki entre VPCs
- **Terraform Remote State**: Estado compartilhado entre contas

### Contas AWS Configuradas
- `361769578479` - Conta de desenvolvimento
- `940482420564` - Conta principal
- `409137744423` - Conta de observabilidade

## 📊 Monitoramento

### Métricas Disponíveis
- Métricas da aplicação Node.js (via ADOT)
- Métricas HTTP server
- Métricas ECS (CPU, memória, tarefas)
- Métricas de load balancer

### Logs Disponíveis
- Logs da aplicação (CloudWatch Logs)
- Logs do FireLens (CloudWatch Logs)
- Logs do ADOT Collector
- Logs do Loki

## 🛠️ Tecnologias Utilizadas

### AWS Services
- **ECS Fargate** - Container orchestration
- **Application Load Balancer** - Load balancing
- **ECR** - Container registry
- **CloudWatch** - Logs e métricas básicas
- **Amazon Managed Prometheus** - Métricas escaláveis
- **Amazon Managed Grafana** - Visualização
- **Secrets Manager** - Gerenciamento de secrets
- **S3** - Armazenamento de logs e dados do Loki
- **IAM** - Controle de acesso

### Observabilidade
- **OpenTelemetry** - Padrão de telemetria
- **AWS Distro for OpenTelemetry (ADOT)** - Coletor de telemetria
- **Prometheus** - Armazenamento e query de métricas
- **Loki** - Agregação de logs
- **Grafana** - Visualização unificada

### Infraestrutura
- **Terraform** >= 1.6.0
- **AWS Provider** ~> 5.0

### Aplicação
- **Node.js**
- **Express**
- **Pino** - Logger estruturado

## 🔧 Configuração

### Variáveis de Ambiente da Aplicação
- `PORT` - Porta do servidor (padrão: 3000)
- `PINO_LOG_FILE` - Arquivo para logs (opcional)

### Variáveis Terraform Principais
Consulte `infra/modules/ecs-deploy/variables.tf` para a lista completa.

Principais:
- `environment` - Ambiente de implantação
- `application` - Nome da aplicação
- `region` - Região AWS
- `enable_metrics` - Habilitar métricas (AMP)
- `enable_firelens` - Habilitar FireLens para logs

## 📈 Escalabilidade

- **Auto Scaling ECS**: Baseado em CPU e requisições
- **Fargate Spot**: Suporte para otimização de custos
- **Loki Escalável**: Configurado para crescer conforme necessário
- **AMP**: Escalável automaticamente

## 💰 Otimização de Custos

- Uso de **Fargate Spot** para tarefas não críticas
- **Lifecycle policies** no S3 para transição e expiração
- **Retenção configurável** de logs
- **Compressão** de logs no S3

## 🔧 Troubleshooting

### Problemas Comuns

#### Loki Health Check Failing
Se os targets do Loki NLB estiverem unhealthy:

1. **Verificar conectividade de rede:**
   ```bash
   # Teste de dentro da VPC
   curl http://$(terraform output -raw loki_nlb_dns_name):3100/ready
   ```

2. **Verificar logs do Loki:**
   ```bash
   aws logs tail $(terraform output -raw loki_cloudwatch_log_group_name) --follow
   ```

3. **Verificar Security Groups:**
   - O Security Group do ECS deve ter permissão para acessar o Security Group do Loki na porta 3100
   - O Security Group do Loki deve permitir tráfego do CIDR da VPC (10.0.0.0/16)

#### Dependências Circulares no Terraform
Se você encontrar erros de dependência circular:

- A regra de Security Group do Loki está em `infra/envs/dev/main.tf` para evitar dependências circulares
- O `task_role_arn` do ADOT é passado como `null` inicialmente para quebrar ciclos de dependência

### Scripts Úteis

#### Listar Todos os Endpoints
```bash
./scripts/get-endpoints.sh
```

#### Ver Status do Serviço ECS
```bash
aws ecs describe-services \
  --cluster $(cd infra/envs/dev && terraform output -raw ecs_cluster_name) \
  --services $(cd infra/envs/dev && terraform output -raw ecs_service_name) \
  --region us-east-1
```

#### Ver Logs do Loki
```bash
aws logs tail $(cd infra/envs/dev && terraform output -raw loki_cloudwatch_log_group_name) \
  --follow \
  --region us-east-1
```

## 📝 Refatoração Recente

O projeto foi recentemente refatorado para melhorar a organização e resolver problemas:

- ✅ Locals movidos para módulos específicos
- ✅ Cada submódulo possui seu próprio `locals.tf`
- ✅ Padrão consistente de `common_tags` em todos os módulos
- ✅ Nomenclatura padronizada via locals
- ✅ Dependências circulares resolvidas (Security Groups, IAM Roles)
- ✅ Health checks do Loki ajustados (TCP temporário para validação de rede)
- ✅ Configuração do Loki para escutar em 0.0.0.0:3100 (IPv4 e IPv6)
- ✅ Script utilitário para listar endpoints (`scripts/get-endpoints.sh`)

## 🤝 Contribuindo

1. Crie uma branch para sua feature
2. Faça commit das mudanças
3. Abra um Pull Request

## 📄 Licença

MIT

## 👥 Autores

DevOps Team - Grupo OTG

## 🔗 Links Úteis

- [AWS Distro for OpenTelemetry](https://aws-otel.github.io/)
- [Amazon Managed Prometheus](https://docs.aws.amazon.com/prometheus/)
- [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Pino Logger](https://getpino.io/)

## 📊 Monitoramento e Observabilidade

### Health Checks

- **Aplicação**: `GET /` ou `GET /status`
- **Loki**: `GET /ready` na porta 3100
- **ECS**: Health checks configurados automaticamente

### Dashboards no Grafana

Após configurar os data sources no Grafana, você pode criar dashboards para:

- **Métricas da Aplicação**: Via Prometheus (ADOT)
- **Logs da Aplicação**: Via CloudWatch Logs Insights ou Loki
- **Métricas de Infraestrutura**: CPU, memória, requisições do ECS
- **Métricas de Load Balancer**: Requisições, latência, erros

---

**Nota**: Este é um projeto de POC (Proof of Concept) para demonstrar capacidades de observabilidade. Ajuste conforme necessário para ambientes de produção.

