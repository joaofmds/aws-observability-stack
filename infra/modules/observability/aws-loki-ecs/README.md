<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_s3_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_execution_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_s3_bucket.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_security_group.loki_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.loki_ingress_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.loki_ingress_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint_service.loki](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDRs permitidos para acessar o Loki via NLB. Ex: VPCs de dev/prd ou ranges da org. | `list(string)` | `[]` | no |
| <a name="input_allowed_security_group_ids"></a> [allowed\_security\_group\_ids](#input\_allowed\_security\_group\_ids) | Security groups permitidos para acessar o Loki (usado em ingress rule baseada em SG). | `list(string)` | `[]` | no |
| <a name="input_application"></a> [application](#input\_application) | Aplicação que utiliza o recurso | `string` | n/a | yes |
| <a name="input_capacity_provider_strategies"></a> [capacity\_provider\_strategies](#input\_capacity\_provider\_strategies) | Lista de estratégias de capacity provider para o serviço ECS.<br/>Se vazio, o serviço usará launch\_type = FARGATE.<br/>Exemplo:<br/>[<br/>  {<br/>    capacity\_provider = "FARGATE"<br/>    weight            = 1<br/>    base              = 1<br/>  },<br/>  {<br/>    capacity\_provider = "FARGATE\_SPOT"<br/>    weight            = 3<br/>  }<br/>] | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = optional(number)<br/>    base              = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Retenção, em dias, do log group do Loki no CloudWatch | `number` | `30` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Se true, cria o bucket S3 para armazenamento do Loki. Se false, usa s3\_bucket\_name existente. | `bool` | `true` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Nome do cluster ECS que será criado para o Loki. Se nulo, será derivado de name\_prefix. | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Ambiente de implantação | `string` | n/a | yes |
| <a name="input_loki_cpu"></a> [loki\_cpu](#input\_loki\_cpu) | CPU da task Fargate (em unidades da AWS, ex: 256, 512, 1024) | `number` | `1024` | no |
| <a name="input_loki_desired_count"></a> [loki\_desired\_count](#input\_loki\_desired\_count) | Número de tasks desejadas para o serviço Loki | `number` | `1` | no |
| <a name="input_loki_image"></a> [loki\_image](#input\_loki\_image) | Imagem Docker do Loki | `string` | `"grafana/loki:3.1.0"` | no |
| <a name="input_loki_memory"></a> [loki\_memory](#input\_loki\_memory) | Memória da task Fargate (em MiB, ex: 512, 1024, 2048) | `number` | `2048` | no |
| <a name="input_loki_port"></a> [loki\_port](#input\_loki\_port) | Porta HTTP do Loki | `number` | `3100` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefixo para nomear recursos (ex: observability-o11y) | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Time responsável pelo recurso | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Lista de subnets privadas para o serviço ECS Fargate | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nome do projeto para prefixar recursos. | `string` | n/a | yes |
| <a name="input_retention_days"></a> [retention\_days](#input\_retention\_days) | Período de retenção de logs no Loki (em dias) | `number` | `30` | no |
| <a name="input_s3_bucket_kms_key_arn"></a> [s3\_bucket\_kms\_key\_arn](#input\_s3\_bucket\_kms\_key\_arn) | ARN da chave KMS para criptografia do bucket S3. Se null, usa AES256. | `string` | `null` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Nome do bucket S3 para Loki. Obrigatório se create\_s3\_bucket = false. Se create\_s3\_bucket = true e não informado, será gerado. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags padrão aplicadas aos recursos | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_vpc_endpoint_allowed_principals"></a> [vpc\_endpoint\_allowed\_principals](#input\_vpc\_endpoint\_allowed\_principals) | Lista de principals IAM (ARNs) que podem criar VPC Endpoints (PrivateLink) para o Loki.<br/>Exemplo: ["arn:aws:iam::940482420564:root", "arn:aws:iam::<prod-account-id>:root"] | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID da VPC onde o Loki será executado | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN do cluster ECS criado para o Loki |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Nome do cluster ECS criado para o Loki |
| <a name="output_loki_cloudwatch_log_group_name"></a> [loki\_cloudwatch\_log\_group\_name](#output\_loki\_cloudwatch\_log\_group\_name) | Nome do log group do Loki no CloudWatch |
| <a name="output_loki_endpoint_http"></a> [loki\_endpoint\_http](#output\_loki\_endpoint\_http) | Endpoint HTTP do Loki (sem TLS, dentro da VPC) |
| <a name="output_loki_nlb_arn"></a> [loki\_nlb\_arn](#output\_loki\_nlb\_arn) | ARN do Network Load Balancer do Loki |
| <a name="output_loki_nlb_dns_name"></a> [loki\_nlb\_dns\_name](#output\_loki\_nlb\_dns\_name) | DNS do NLB do Loki |
| <a name="output_loki_s3_bucket_name"></a> [loki\_s3\_bucket\_name](#output\_loki\_s3\_bucket\_name) | Nome do bucket S3 utilizado pelo Loki |
| <a name="output_loki_service_name"></a> [loki\_service\_name](#output\_loki\_service\_name) | Nome do serviço ECS do Loki |
| <a name="output_loki_target_group_arn"></a> [loki\_target\_group\_arn](#output\_loki\_target\_group\_arn) | ARN do target group do Loki |
| <a name="output_loki_task_definition_arn"></a> [loki\_task\_definition\_arn](#output\_loki\_task\_definition\_arn) | ARN da task definition do Loki |
| <a name="output_loki_task_security_group_id"></a> [loki\_task\_security\_group\_id](#output\_loki\_task\_security\_group\_id) | ID do Security Group das tasks ECS do Loki |
| <a name="output_loki_vpc_endpoint_service_name"></a> [loki\_vpc\_endpoint\_service\_name](#output\_loki\_vpc\_endpoint\_service\_name) | Nome do VPC Endpoint Service (PrivateLink) para o Loki, usado pelas VPCs consumidoras |
<!-- END_TF_DOCS -->