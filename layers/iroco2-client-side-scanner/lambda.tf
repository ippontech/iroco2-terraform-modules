data "archive_file" "layers" {
  type        = "zip"
  source_dir  = "${path.module}/layers"
  output_path = "${path.module}/layers.zip"
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/lambda.zip"
}

# Lambda Layer for helper scripts
resource "aws_lambda_layer_version" "helper_scripts" {
  layer_name          = local.layer_name
  description         = "Scripts for IROCO2 helpers"
  compatible_runtimes = ["python3.9", "python3.10", "python3.11"]

  filename = "${path.module}/layers.zip"

}

# Lambda Function
resource "aws_lambda_function" "processing" {
  function_name = var.lambda_function_name
  description   = "IROCO2 CUR Scanner - Processes CUR data for carbon impact analysis"

  role    = aws_iam_role.lambda_execution.arn
  handler = "cur_scrapper.handler"
  runtime = "python3.11"

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  # Lambda layers
  layers = [
    aws_lambda_layer_version.helper_scripts.arn,
    var.aws_sdk_pandas_layer_arn
  ]

  filename = "${path.module}/lambda.zip"

  # Environment variables
  environment {
    variables = {
      IROCO2_API_ENDPOINT     = var.iroco2_api_endpoint
      IROCO2_GATEWAY_ENDPOINT = var.iroco2_gateway_endpoint
      IROCO2_API_KEY          = var.iroco2_api_key
    }
  }

  # Logging configuration
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.lambda.name
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_s3_kms_access,
    aws_cloudwatch_log_group.lambda
  ]
}

# Lambda permission for S3 to invoke the function
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cur_output.arn
}
