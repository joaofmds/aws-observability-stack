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
| [aws_prometheus_workspace.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | Alias legível para o Workspace do AMP | `string` | n/a | yes |
| <a name="input_application"></a> [application](#input\_application) | Aplicação que utiliza o recurso | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Ambiente de implantação | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Time responsável pelo recurso | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nome do projeto para prefixar recursos. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Região AWS | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags padrão aplicadas aos recursos | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_query_endpoint"></a> [query\_endpoint](#output\_query\_endpoint) | Endpoint para consultas (Grafana ou Prometheus UI) |
| <a name="output_remote_write_endpoint"></a> [remote\_write\_endpoint](#output\_remote\_write\_endpoint) | Endpoint para uso com ADOT / Prometheus Remote Write |
| <a name="output_workspace_arn"></a> [workspace\_arn](#output\_workspace\_arn) | ARN do workspace AMP |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | ID do workspace AMP |
<!-- END_TF_DOCS -->