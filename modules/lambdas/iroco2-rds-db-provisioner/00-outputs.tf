output "rendered_template" {
  value = templatefile("${path.module}/lambda_payload.json.tpl",
    {
      databases   = jsonencode(var.databases)
      schemas     = jsonencode(var.schemas)
      roles       = jsonencode(var.roles)
      users       = jsonencode(var.users)
      grants      = jsonencode(var.grants)
      auto_grants = jsonencode(var.auto_grants)
    }
  )
}

output "lambda_role_arn" {
  value = var.lambda_iam_role_arn != "" ? var.lambda_iam_role_arn : aws_iam_role.lambda[0].arn
}