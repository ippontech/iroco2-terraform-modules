# IROCO2 Client Side Scanner Terraform Module

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%3E%3D5.0-FF9900)](https://aws.amazon.com/)

This Terraform module creates the AWS infrastructure for the IROCO2 Client Side Scanner, which processes Cost and Usage Report (CUR) data for carbon impact analysis.

> **Open Source Ready**: This module is designed for easy integration into open source projects and can be used by anyone to analyze AWS carbon footprint data.

## Quick Start

Want to get started quickly? Check out our [basic example](examples/basic/) which includes:

- 📋 **Step-by-step setup guide**
- 🔧 **Pre-configured variables**
- 📖 **Detailed documentation**
- 🚀 **Ready-to-deploy configuration**

```bash
# Clone the example
cp -r examples/basic my-iroco2-deployment
cd my-iroco2-deployment

# Configure your settings
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your AWS details

# Deploy
terraform init && terraform apply
```

## Overview

The module provisions the following AWS resources:

- **S3 Bucket**: Encrypted storage for CUR output with event notifications
- **Lambda Function**: Python 3.11 runtime for processing CUR data
- **Lambda Layer**: Custom helper scripts for IROCO2 functionality
- **IAM Role & Policies**: Execution permissions for Lambda with least privilege access
- **CloudWatch Log Group**: Centralized logging with KMS encryption
- **S3 Bucket Policy**: Organization-based access control
- **Lambda Permissions**: S3 trigger configuration

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   S3 Bucket     │───▶│  Lambda Function │───▶│  IROCO2 API     │
│  (CUR Output)   │    │  (CUR Scanner)   │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │
         │                       ▼
         │              ┌─────────────────┐
         │              │ CloudWatch Logs │
         │              │                 │
         │              └─────────────────┘
         │
         ▼
┌─────────────────┐
│   KMS Key       │
│ (Encryption)    │
└─────────────────┘
```

## Usage

### Basic Usage

```hcl
module "iroco2_client_side_scanner" {
  source = "./lambdas/functions/iroco2-client-side-scanner/"

  # Required variables
  kms_key_arn                = "arn:aws:kms:eu-west-3:123456789012:key/12345678-1234-1234-1234-123456789012"
  aws_org_id                = "o-1234567890"
  cur_output_bucket_name    = "my-cur-output-bucket"
  iroco2_api_endpoint       = "https://api.iroco2.example.com"
  iroco2_gateway_endpoint   = "https://gateway.iroco2.example.com"
  iroco2_api_key           = "your-api-key-here"

  # Optional variables with defaults
  lambda_function_name     = "IROCO2-CUR-SCRAPPER"
  lambda_log_group_name   = "/aws/lambda/IROCO2-CUR-SCRAPPER"
  lambda_timeout          = 900
  lambda_memory_size      = 512
  log_retention_days      = 14

  common_tags = {
    Environment = "production"
    Project     = "IROCO2"
    Owner       = "data-team"
  }
}
```

### Advanced Usage with Custom Configuration

```hcl
module "iroco2_client_side_scanner" {
  source = "./lambdas/functions/iroco2-client-side-scanner/tf"

  # Required variables
  kms_key_arn                = data.aws_kms_key.main.arn
  aws_org_id                = var.organization_id
  cur_output_bucket_name    = "${var.environment}-cur-output-${random_id.bucket_suffix.hex}"
  iroco2_api_endpoint       = var.iroco2_api_endpoint
  iroco2_gateway_endpoint   = var.iroco2_gateway_endpoint
  iroco2_api_key           = data.aws_secretsmanager_secret_version.iroco2_api_key.secret_string

  # Custom configuration
  lambda_function_name     = "${var.environment}-iroco2-cur-scanner"
  lambda_log_group_name   = "/aws/lambda/${var.environment}-iroco2-cur-scanner"
  lambda_timeout          = 600
  lambda_memory_size      = 1024
  log_retention_days      = 30

  common_tags = merge(var.common_tags, {
    Environment = var.environment
    Module      = "iroco2-client-side-scanner"
  })
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| aws_s3_bucket.cur_output | resource |
| aws_s3_bucket_versioning.cur_output | resource |
| aws_s3_bucket_server_side_encryption_configuration.cur_output | resource |
| aws_s3_bucket_public_access_block.cur_output | resource |
| aws_s3_bucket_policy.cur_output | resource |
| aws_s3_bucket_notification.cur_output | resource |
| aws_lambda_function.processing | resource |
| aws_lambda_layer_version.helper_scripts | resource |
| aws_lambda_permission.s3_invoke | resource |
| aws_iam_role.lambda_execution | resource |
| aws_iam_role_policy_attachment.lambda_basic_execution | resource |
| aws_iam_role_policy.lambda_s3_kms_access | resource |
| aws_cloudwatch_log_group.lambda | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| kms_key_arn | The KMS key ARN to encrypt the bucket and logs | `string` | n/a | yes |
| aws_org_id | The AWS Organization ID | `string` | n/a | yes |
| cur_output_bucket_name | Name for the CUR data export in the console | `string` | n/a | yes |
| bcm_data_export_name | The S3 bucket name for the CUR output | `string` | IROCO2-REPORT | no |
| iroco2_api_endpoint | The IroCO2 API endpoint | `string` | n/a | yes |
| iroco2_gateway_endpoint | The IroCO2 Gateway endpoint | `string` | n/a | yes |
| iroco2_api_key | The IroCO2 API token | `string` | n/a | yes |
| lambda_function_name | Name of the Lambda function | `string` | `"IROCO2-CUR-SCRAPPER"` | no |
| lambda_log_group_name | Log group name for lambda | `string` | `"/aws/lambda/IROCO2-CUR-SCRAPPER"` | no |
| lambda_timeout | Lambda function timeout in seconds | `number` | `900` | no |
| lambda_memory_size | Lambda function memory size in MB | `number` | `512` | no |
| log_retention_days | CloudWatch log retention in days | `number` | `14` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{"Project": "IROCO2"}` | no |
| aws_sdk_pandas_layer_arn | ARN of the AWS SDK Pandas layer | `string` | `"arn:aws:lambda:eu-west-3:336392948345:layer:AWSSDKPandas-Python311:18"` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_name | Name of the created Lambda function for CUR extraction |
| lambda_function_arn | ARN of the created Lambda function |
| lambda_function_invoke_arn | Invoke ARN of the Lambda function |
| s3_bucket_name | Name of the S3 bucket for CUR output |
| s3_bucket_arn | ARN of the S3 bucket for CUR output |
| s3_bucket_domain_name | Domain name of the S3 bucket |
| lambda_execution_role_arn | ARN of the Lambda execution role |
| lambda_execution_role_name | Name of the Lambda execution role |
| lambda_layer_arn | ARN of the helper scripts Lambda layer |
| lambda_layer_version | Version of the helper scripts Lambda layer |
| cloudwatch_log_group_name | Name of the CloudWatch log group |
| cloudwatch_log_group_arn | ARN of the CloudWatch log group |

## Features

### Security

- **KMS Encryption**: All data at rest is encrypted using customer-managed KMS keys
- **IAM Least Privilege**: Lambda execution role has minimal required permissions
- **Organization Access Control**: S3 bucket policy restricts access to organization members
- **Secure Transport**: All S3 operations require HTTPS

### Monitoring & Logging

- **CloudWatch Integration**: Centralized logging with configurable retention
- **Structured Logging**: Lambda function uses structured logging format
- **Error Tracking**: Failed executions are logged for troubleshooting

### Scalability

- **Configurable Resources**: Memory and timeout can be adjusted based on workload
- **Layer Management**: Helper scripts are packaged as reusable Lambda layers
- **Event-Driven**: S3 events automatically trigger processing

## Triggers

The Lambda function is automatically triggered by S3 events:

- **Event Type**: `s3:ObjectCreated:Copy`
- **File Filters**:
  - Files ending with `.parquet`
  - Files ending with `.csv.zip`

## Environment Variables

The Lambda function receives the following environment variables:

- `IROCO2_API_ENDPOINT`: API endpoint for IROCO2 service
- `IROCO2_GATEWAY_ENDPOINT`: Gateway endpoint for IROCO2 service
- `IROCO2_API_KEY`: Authentication token for IROCO2 API

## Migration from CloudFormation

This module is designed as a direct replacement for the CloudFormation template in `lambda.yaml`. Key improvements include:

1. **Better Resource Management**: Terraform state tracking
2. **Input Validation**: Variable validation rules
3. **Modular Design**: Reusable across environments
4. **Enhanced Documentation**: Comprehensive usage examples
5. **Flexible Configuration**: More customization options

## Troubleshooting

### Common Issues

1. **KMS Key Access**: Ensure the KMS key policy allows Lambda service access
2. **S3 Permissions**: Verify the Lambda execution role has GetObject permissions
3. **Layer Compatibility**: Ensure the helper scripts layer is compatible with Python 3.11
4. **Organization ID**: Verify the AWS Organization ID format is correct

### Debugging

Check CloudWatch logs for Lambda execution details:

```bash
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/IROCO2-CUR-SCRAPPER"
aws logs get-log-events --log-group-name "/aws/lambda/IROCO2-CUR-SCRAPPER" --log-stream-name "LATEST"
```

## Development Setup

### Prerequisites

Before working with this module, ensure you have the following tools installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [pre-commit](https://pre-commit.com/#installation)
- [TFLint](https://github.com/terraform-linters/tflint#installation)
- [tfsec](https://github.com/aquasecurity/tfsec#installation)
- [Checkov](https://www.checkov.io/1.Welcome/Quick%20Start.html) (optional, installed via pip)
- [terraform-docs](https://terraform-docs.io/user-guide/installation/) (optional)

### Setup Pre-commit Hooks

This module includes pre-commit configuration that automatically validates your changes:

```bash
# Navigate to the module directory
cd lambdas/functions/iroco2-client-side-scanner/tf

# Install pre-commit hooks (one-time setup)
pre-commit install

# Optional: Run hooks on all files to test setup
pre-commit run --all-files
```

### What the Pre-commit Hooks Do

The pre-commit configuration automatically runs the following checks on every commit:

1. **General Checks**:
   - Remove trailing whitespace
   - Fix end-of-file formatting
   - Validate YAML and JSON files
   - Check for large files and merge conflicts

2. **Terraform Validation**:
   - Format Terraform files (`terraform fmt`)
   - Validate Terraform syntax (`terraform validate`)
   - Run TFLint for best practices
   - Security scanning with tfsec and Checkov
   - Update documentation automatically

3. **Security**:
   - Scan for secrets and sensitive data
   - Check for security misconfigurations

### Manual Commands

If you need to run checks manually:

```bash
# Format Terraform files
terraform fmt -recursive

# Validate Terraform configuration
terraform validate

# Run TFLint
tflint

# Run security checks
tfsec .
checkov -f . --framework terraform

# Run all pre-commit hooks manually
pre-commit run --all-files
```

## Deployment Guide

### Prerequisites

Before deploying this module, ensure you have:

1. **AWS CLI configured** with appropriate permissions
2. **Terraform installed** (>= 1.0)
3. **Required AWS resources** created (see below)

### Required AWS Resources

You need to create these resources before deploying:

1. **KMS Key** for encryption
2. **S3 Bucket** for Lambda layers with the helper scripts ZIP uploaded
3. **S3 Bucket** for Lambda function code with the function ZIP uploaded
4. **AWS Organization ID** (if using AWS Organizations)
5. **IROCO2 API credentials** and endpoints

### Step-by-Step Deployment

1. **Configure AWS Profile**:
   ```bash
   aws configure --profile default
   # or use existing profile
   export AWS_PROFILE=default
   ```

2. **Navigate to module directory**:
   ```bash
   cd lambdas/functions/iroco2-client-side-scanner/tf
   ```

3. **Update variables**:
   ```bash
   # Copy example file
   cp terraform.tfvars.example terraform.tfvars

   # Edit with your actual values
   nano terraform.tfvars
   ```

4. **Initialize Terraform**:
   ```bash
   terraform init
   ```

5. **Plan deployment**:
   ```bash
   terraform plan
   ```

6. **Deploy the module**:
   ```bash
   terraform apply
   ```

7. **Verify deployment**:
   ```bash
   # Check outputs
   terraform output

   # Verify Lambda function
   aws lambda get-function --function-name IROCO2-CUR-SCRAPPER-dev
   ```

### Example terraform.tfvars

```hcl
# Update these with your actual values
kms_key_arn                = "arn:aws:kms:eu-west-3:123456789012:key/abcd1234-..."
aws_org_id                = "o-1234567890"
cur_output_bucket_name    = "iroco2-cur-output-unique-suffix"
bcm_data_export_name      = "IROCO2-REPORT"
iroco2_api_endpoint       = "https://api.iroco2.example.com"
iroco2_gateway_endpoint   = "https://gateway.iroco2.example.com"
iroco2_api_key           = "your-secret-api-key"

common_tags = {
  Environment = "production"
  Project     = "IROCO2"
  Owner       = "data-team"
}
```

### Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources created by this module, including the S3 bucket and any data it contains.

## Contributing

When modifying this module:

1. Ensure pre-commit hooks are installed and passing
2. Update variable descriptions and validation rules
3. Add new outputs for any additional resources
4. Update this README with new features or changes
5. Test the module in a development environment
6. Ensure backward compatibility when possible

## License

This module is part of the IROCO2 project and follows the project's licensing terms.
