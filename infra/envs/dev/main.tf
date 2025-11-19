module "grafana" {
  source                   = "git@github.com:WiiAscendTech/TerraformModules//aws-grafana"
  grafana_service_role_arn = module.grafana_iam_role.role_arn
  authentication_providers = ["AWS_SSO"]
  enabled_data_sources     = ["CLOUDWATCH", "XRAY", "PROMETHEUS"]
  grafana_alerting_enabled = true
  enable_plugin_management = true

  vpc_id         = data.terraform_remote_state.core_infra.outputs.vpc_id
  vpc_subnet_ids = data.terraform_remote_state.core_infra.outputs.private_subnet_ids

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
}

module "terraform_backend_role" {
  source = "git@github.com:WiiAscendTech/TerraformModules//aws-iam-role"

  role_name        = "terraform-backend-access-role"
  policy_name      = "terraform-backend-access-policy"
  role_description = "Role para acesso ao backend remoto do Terraform"

  assume_role_policy_json = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Principal : {
            AWS : [
              "arn:aws:iam::361769578479:root",
              "arn:aws:iam::940482420564:root",
              "arn:aws:iam::940482420564:role/backend-backoffice-ecs-task-role-dev"
            ]
          },
          Action : "sts:AssumeRole"
        }
      ]
    }
  )

  policy_json = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "AllowCrossAccountAccess",
          Effect : "Allow",
          Action : [
            "s3:GetObject",
            "s3:ListBucket"
          ],
          Resource : [
            "arn:aws:s3:::wiiascend-tfstate-o11y",
            "arn:aws:s3:::wiiascend-tfstate-o11y/*"
          ]
        },
        {
          Sid : "DynamoDBLocking",
          Effect : "Allow",
          Action : [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem",
            "dynamodb:UpdateItem"
          ],
          Resource : "arn:aws:dynamodb:us-east-1:409137744423:table/terraform-locks"
        },
        {
          Sid    = "AllowAMPWriteFromAssumedRoles",
          Effect = "Allow",
          Action = [
            "aps:RemoteWrite"
          ],
          Resource = "arn:aws:aps:us-east-1:409137744423:workspace/ws-e649571b-f79c-4af4-b9bd-cc7430795639"
        }
      ]
    }
  )

  policy_description = "Permissões para acesso ao bucket S3 do backend remoto"
  prevent_destroy    = false

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
}

module "grafana_iam_role" {
  source = "git@github.com:WiiAscendTech/TerraformModules//aws-iam-role"

  role_name        = "grafana-service-role"
  policy_name      = "grafana-service-policy"
  role_description = "Role usada pelo Amazon Managed Grafana"

  assume_role_policy_json = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "grafana.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  policy_json = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowPrometheusAccess",
        Effect : "Allow",
        Action : [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ],
        Resource : "*"
      },
      {
        Sid : "AllowCloudWatchAccess",
        Effect : "Allow",
        Action : [
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms"
        ],
        Resource : "*"
      },
      {
        Sid : "AllowLogsAccess",
        Effect : "Allow",
        Action : [
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "logs:StartQuery",
          "logs:GetQueryResults"
        ],
        Resource : "*"
      },
      {
        Sid : "AllowXrayAccess",
        Effect : "Allow",
        Action : [
          "xray:GetTraceSummaries",
          "xray:GetServiceGraph",
          "xray:BatchGetTraces",
          "xray:GetTraceGraph"
        ],
        Resource : "*"
      },
      {
        Sid : "AllowSelfAssumeRole",
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Resource : "arn:aws:iam::409137744423:role/grafana-service-role"
      },
      {
        Sid : "AllowSESSendEmail",
        Effect : "Allow",
        Action : [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource : "*"
      },
      {
        Sid    = "AllowSnsPublishToAlertsTopic",
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = module.infra_alerts_sns.arn
      }
    ]
  })

  policy_description = "Permissões para CloudWatch, Logs e X-Ray para Grafana"
  prevent_destroy    = false

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
}

module "lambda_sns_ses_role" {
  source = "git@github.com:WiiAscendTech/TerraformModules//aws-iam-role"

  role_name        = "sns-ses-handler"
  policy_name      = "sns-ses-handler-policy"
  role_description = "Permissões para função Lambda enviar e-mails via SES"

  assume_role_policy_json = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  policy_json = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "AllowSESSend",
        Effect : "Allow",
        Action : [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource : "*"
      },
      {
        Sid : "AllowCloudWatchLogs",
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : "*"
      }
    ]
  })

  environment     = var.environment
  project_name    = var.project_name
  owner           = var.owner
  application     = var.application
  prevent_destroy = false
}

module "loki_ecs" {
  source = "git@github.com:WiiAscendTech/tf-aws-modules//aws-loki-ecs"

  name_prefix        = "o11y"
  vpc_id             = data.terraform_remote_state.core_infra.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.core_infra.outputs.private_subnet_ids
  loki_desired_count = 1
  ecs_cluster_name = "o11y-loki-cluster"

  retention_days                = 30
  cloudwatch_log_retention_days = 3

  capacity_provider_strategies = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
      base              = 1
    }
  ]

  allowed_cidr_blocks = [
    "10.0.0.0/16",
  ]

  vpc_endpoint_allowed_principals = [
    "arn:aws:iam::940482420564:root",
    "arn:aws:iam::361769578479:root"
  ]

  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
}

module "prometheus" {
  source       = "git@github.com:WiiAscendTech/TerraformModules//aws-prometheus"
  alias        = "central-prometheus"
  region       = var.region
  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
  application  = var.application
}
