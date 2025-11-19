<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_grafana_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/grafana_workspace) | resource |
| [aws_security_group.workspace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_access_type"></a> [account\_access\_type](#input\_account\_access\_type) | Tipo de acesso à conta (CURRENT\_ACCOUNT ou ORGANIZATION) | `string` | `"CURRENT_ACCOUNT"` | no |
| <a name="input_application"></a> [application](#input\_application) | Aplicação que utiliza o recurso | `string` | n/a | yes |
| <a name="input_authentication_providers"></a> [authentication\_providers](#input\_authentication\_providers) | Lista de provedores de autenticação (ex: AWS\_SSO) | `list(string)` | <pre>[<br/>  "AWS_SSO"<br/>]</pre> | no |
| <a name="input_enable_plugin_management"></a> [enable\_plugin\_management](#input\_enable\_plugin\_management) | Se true, permite que administradores do Grafana gerenciem plugins. | `bool` | `true` | no |
| <a name="input_enabled_data_sources"></a> [enabled\_data\_sources](#input\_enabled\_data\_sources) | Lista de fontes de dados a habilitar no Grafana | `list(string)` | <pre>[<br/>  "CLOUDWATCH",<br/>  "XRAY"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Ambiente de implantação | `string` | n/a | yes |
| <a name="input_grafana_alerting_enabled"></a> [grafana\_alerting\_enabled](#input\_grafana\_alerting\_enabled) | Se true, habilita o sistema de alertas unificado do Grafana. | `bool` | `true` | no |
| <a name="input_grafana_service_role_arn"></a> [grafana\_service\_role\_arn](#input\_grafana\_service\_role\_arn) | ARN da IAM Role para o Grafana acessar os serviços | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefixo opcional para compor o nome do workspace | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Responsável pelo recurso | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nome do projeto | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags customizadas | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID da VPC onde o workspace Grafana terá ENIs para acessar datasources privados. Se null, o workspace não terá vpc\_configuration. | `string` | `null` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | Subnets da VPC onde o workspace Grafana criará ENIs. Usado quando vpc\_id não é null. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_workspace_arn"></a> [grafana\_workspace\_arn](#output\_grafana\_workspace\_arn) | ARN do workspace Grafana |
| <a name="output_grafana_workspace_id"></a> [grafana\_workspace\_id](#output\_grafana\_workspace\_id) | ID do workspace Grafana |
| <a name="output_grafana_workspace_security_group_id"></a> [grafana\_workspace\_security\_group\_id](#output\_grafana\_workspace\_security\_group\_id) | Security Group anexado aos ENIs do workspace Grafana (se vpc\_configuration estiver habilitada) |
| <a name="output_grafana_workspace_url"></a> [grafana\_workspace\_url](#output\_grafana\_workspace\_url) | URL do workspace Grafana |
<!-- END_TF_DOCS -->