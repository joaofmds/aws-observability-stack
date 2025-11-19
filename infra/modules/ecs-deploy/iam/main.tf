
resource "aws_iam_role" "this" {
  name               = local.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy_json

  tags = merge(local.common_tags, {
    Name = local.role_name
  })
}

resource "aws_iam_policy" "this" {
  count       = var.policy_json != null ? 1 : 0
  name        = local.policy_name
  description = var.policy_description
  policy      = var.policy_json

  tags = merge(local.common_tags, {
    Name = local.policy_name
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.policy_json != null ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}