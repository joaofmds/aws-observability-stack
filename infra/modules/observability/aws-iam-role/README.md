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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Aplicação que utiliza o recurso | `string` | n/a | yes |
| <a name="input_assume_role_policy_json"></a> [assume\_role\_policy\_json](#input\_assume\_role\_policy\_json) | Política de confiança (JSON) para a IAM Role | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Ambiente de implantação | `string` | n/a | yes |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | Lista de ARNs de políticas gerenciadas para anexar à role | `list(string)` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefixo para compor o nome da role e policy | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Time responsável pelo recurso | `string` | n/a | yes |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Descrição da política IAM | `string` | `null` | no |
| <a name="input_policy_json"></a> [policy\_json](#input\_policy\_json) | Política IAM (JSON) a ser anexada à role | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Nome da IAM Policy | `string` | n/a | yes |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Se true, protege a role/policy de destruição acidental | `bool` | `true` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Nome do projeto para prefixar recursos. | `string` | n/a | yes |
| <a name="input_role_description"></a> [role\_description](#input\_role\_description) | Descrição da IAM Role | `string` | `null` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Nome da IAM Role | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags padrão aplicadas aos recursos | `map(string)` | <pre>{<br/>  "ManagedBy": "Terraform"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_attached_managed_policies"></a> [attached\_managed\_policies](#output\_attached\_managed\_policies) | Lista de ARNs de políticas gerenciadas anexadas |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | ARN da política IAM criada (se aplicável) |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN da IAM Role criada |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Nome da IAM Role criada |
<!-- END_TF_DOCS -->