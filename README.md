# POC Observability - AWS

Prova de Conceito (POC) de uma stack completa de observabilidade na AWS, demonstrando a integração de logs, métricas e traces utilizando serviços gerenciados da AWS e ferramentas de observabilidade open-source.

## 📋 Visão Geral

Este projeto implementa uma arquitetura de observabilidade moderna e escalável, utilizando:

- **Amazon Managed Prometheus (AMP)** para métricas
- **AWS X-Ray** para traces distribuídos
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
  - Envia traces para AWS X-Ray
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
  - Data sources: CloudWatch, X-Ray, Prometheus
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

### Traces
```
Aplicação (OTLP)
    ↓
ADOT Collector (recebe OTLP)
    ↓
AWS X-Ray
    ↓
Grafana (X-Ray Data Source)
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
│   └── README.md                # Documentação da aplicação
│
├── infra/                        # Infraestrutura Terraform
│   ├── envs/                    # Ambientes (dev, staging, prod)
│   │   └── dev/
│   │       ├── main.tf          # Módulos principais
│   │       ├── variables.tf     # Variáveis do ambiente
│   │       ├── outputs.tf       # Outputs do ambiente
│   │       └── terraform.tfvars # Valores das variáveis
│   │
│   └── modules/                 # Módulos Terraform reutilizáveis
│       ├── ecs-deploy/          # Módulo completo de deploy ECS
│       │   ├── adot/            # Módulo ADOT
│       │   ├── alb/             # Módulo ALB
│       │   ├── ecr/             # Módulo ECR
│       │   ├── ecs/             # Módulo ECS
│       │   ├── firelens/        # Módulo FireLens
│       │   ├── iam/             # Módulo IAM
│       │   ├── secrets-manager/ # Módulo Secrets Manager
│       │   ├── variables.tf     # Variáveis do módulo
│       │   ├── versions.tf      # Versões dos providers
│       │   └── data.tf          # Data sources
│       │
│       └── observability/       # Módulos de observabilidade
│           ├── aws-grafana/     # Módulo Grafana
│           ├── aws-loki-ecs/    # Módulo Loki
│           ├── aws-prometheus/  # Módulo Prometheus
│           └── aws-iam-role/    # Módulo IAM Role reutilizável
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

### Traces Disponíveis
- Traces distribuídos via X-Ray
- Service map
- Análise de performance

## 🛠️ Tecnologias Utilizadas

### AWS Services
- **ECS Fargate** - Container orchestration
- **Application Load Balancer** - Load balancing
- **ECR** - Container registry
- **CloudWatch** - Logs e métricas básicas
- **X-Ray** - Distributed tracing
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
- `enable_traces` - Habilitar traces (X-Ray)
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

## 📝 Refatoração Recente

O projeto foi recentemente refatorado para melhorar a organização:

- ✅ Locals movidos para módulos específicos
- ✅ Cada submódulo possui seu próprio `locals.tf`
- ✅ Padrão consistente de `common_tags` em todos os módulos
- ✅ Nomenclatura padronizada via locals

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

---

**Nota**: Este é um projeto de POC (Proof of Concept) para demonstrar capacidades de observabilidade. Ajuste conforme necessário para ambientes de produção.

