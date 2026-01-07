resource "null_resource" "invoke_lambda" {
  triggers = {
    rendered_payload = templatefile("${path.module}/lambda_payload.json.tpl",
      {
        databases   = jsonencode(var.databases)
        schemas     = jsonencode(var.schemas)
        roles       = jsonencode(var.roles)
        users       = jsonencode(var.users)
        grants      = jsonencode(var.grants)
        auto_grants = jsonencode(var.auto_grants)
      }
    )
    source_code_hash       = aws_lambda_function.this.source_code_hash
    lambda_last_modified   = aws_lambda_function.this.last_modified
    force_invoke_timestamp = var.lambda_force_invoke ? timestamp() : ""
  }

  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke \
        --function-name ${var.lambda_function_name} \
        --payload file://lambda_payload.json \
        --cli-binary-format raw-in-base64-out \
        ${path.module}/lambda_response.json
    EOT
  }

  depends_on = [
    local_file.lambda_payload_json,
    aws_lambda_function.this
  ]
}

resource "local_file" "lambda_payload_json" {
  content = templatefile("${path.module}/lambda_payload.json.tpl",
    {
      databases   = jsonencode(var.databases)
      schemas     = jsonencode(var.schemas)
      roles       = jsonencode(var.roles)
      users       = jsonencode(var.users)
      grants      = jsonencode(var.grants)
      auto_grants = jsonencode(var.auto_grants)
    }
  )
  filename             = "lambda_payload.json"
  directory_permission = "0744"
  file_permission      = "0744"
}

resource "aws_lambda_function" "this" {
  role          = var.lambda_iam_role_arn != "" ? var.lambda_iam_role_arn : aws_iam_role.lambda[0].arn
  function_name = var.lambda_function_name
  runtime       = "provided.al2"
  handler       = "rds-provisioner"

  timeout = var.lambda_timeout

  filename         = "${path.module}/function.zip"
  source_code_hash = filebase64sha256("${path.module}/function.zip")

  memory_size = 128

  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      "DB_HOST"          = var.rds_endpoint
      "DB_PORT"          = var.rds_db_port
      "DB_NAME"          = var.rds_default_db_name
      "DB_PASSWORD_ARN"  = var.rds_secret_arn
      "DB_USER"          = var.rds_db_user
      "SSL_MODE"         = var.rds_ssl_mode
      "DB_DRIVER"        = var.rds_db_driver
      "SECRETS_PROVIDER" = "AWS"
      "LOG_LEVEL"        = var.lambda_log_level
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}