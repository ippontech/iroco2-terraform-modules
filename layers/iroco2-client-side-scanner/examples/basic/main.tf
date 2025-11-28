# Basic example of using the IROCO2 Client Side Scanner module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}




# Use the IROCO2 Client Side Scanner module
module "iroco2_scanner" {
  source = "../../."

  # Required variables
  kms_key_arn             = "arn:aws:kms:eu-west-3:<id>:key/<key>" # Manually create symetrical key and report ARN here
  aws_org_id              = "o-yn7toj4ob7"
  cur_output_bucket_name  = "iroco-cur-bucket-toto"
  iroco2_api_endpoint     = "https://api.iroco2.example.com"
  iroco2_gateway_endpoint = "https://gateway.iroco2.example.com"
  iroco2_api_key          = "your-api-key-here"
  bcm_data_export_name    = "IROCO2-REPORT-TEST"
  lambda_function_name    = "test_deploy_iroco2"
  lambda_log_group_name   = "test-deploy-iroco2"
  # Common tags
  common_tags = {
    Environment = "development"
    Project     = "IROCO2"
    Owner       = "data-team"
    ManagedBy   = "Terraform"
  }

}

# Outputs
output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = module.iroco2_scanner.lambda_function_arn
}

output "s3_bucket_name" {
  description = "Name of the CUR output S3 bucket"
  value       = module.iroco2_scanner.s3_bucket_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for monitoring"
  value       = module.iroco2_scanner.cloudwatch_log_group_name
}
