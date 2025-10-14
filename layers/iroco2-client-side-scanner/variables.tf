variable "kms_key_arn" {
  description = "The KMS key ARN to encrypt the bucket and logs"
  type        = string
  validation {
    condition     = can(regex("^arn:aws:kms:", var.kms_key_arn))
    error_message = "The KMS key ARN must be a valid AWS KMS key ARN."
  }
}

variable "aws_org_id" {
  description = "The AWS Organization ID"
  type        = string
  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.aws_org_id))
    error_message = "The AWS Organization ID must be in the format o-xxxxxxxxxx."
  }
}

variable "cur_output_bucket_name" {
  description = "The S3 bucket name for the CUR output"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.cur_output_bucket_name))
    error_message = "The bucket name must be a valid S3 bucket name."
  }
}

variable "iroco2_api_endpoint" {
  description = "The IroCO2 API endpoint"
  type        = string
  validation {
    condition     = can(regex("^https?://", var.iroco2_api_endpoint))
    error_message = "The API endpoint must be a valid HTTP or HTTPS URL."
  }
}

variable "iroco2_gateway_endpoint" {
  description = "The IroCO2 Gateway endpoint"
  type        = string
  validation {
    condition     = can(regex("^https?://", var.iroco2_gateway_endpoint))
    error_message = "The Gateway endpoint must be a valid HTTP or HTTPS URL."
  }
}

variable "iroco2_api_key" {
  description = "The IroCO2 API token"
  type        = string
  sensitive   = true
}

variable "lambda_log_group_name" {
  description = "Log group name for lambda"
  type        = string
  default     = "/aws/lambda/IROCO2-CUR-SCRAPPER"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "IROCO2-CUR-SCRAPPER"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 900
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 512
  validation {
    condition     = var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240
    error_message = "Lambda memory size must be between 128 and 10240 MB."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention value."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project = "IROCO2"
  }
}

variable "aws_sdk_pandas_layer_arn" {
  description = "ARN of the AWS SDK Pandas layer"
  type        = string
  default     = "arn:aws:lambda:eu-west-3:336392948345:layer:AWSSDKPandas-Python311:18"
}

variable "bcm_data_export_name" {
  description = "Name for the CUR data export in the console"
  type        = string
  default     = "IROCO2-REPORT"
}
