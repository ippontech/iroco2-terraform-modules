output "lambda_function_name" {
  description = "Name of the created Lambda function for CUR extraction"
  value       = aws_lambda_function.processing.function_name
}

output "lambda_function_arn" {
  description = "ARN of the created Lambda function"
  value       = aws_lambda_function.processing.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.processing.invoke_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for CUR output"
  value       = aws_s3_bucket.cur_output.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for CUR output"
  value       = aws_s3_bucket.cur_output.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.cur_output.bucket_domain_name
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "lambda_execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.name
}

output "lambda_layer_arn" {
  description = "ARN of the helper scripts Lambda layer"
  value       = aws_lambda_layer_version.helper_scripts.arn
}

output "lambda_layer_version" {
  description = "Version of the helper scripts Lambda layer"
  value       = aws_lambda_layer_version.helper_scripts.version
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.arn
}
