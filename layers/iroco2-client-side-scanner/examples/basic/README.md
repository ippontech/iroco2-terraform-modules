# Basic Example - IROCO2 Client Side Scanner

This example demonstrates how to use the IROCO2 Client Side Scanner Terraform module in your own project.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **AWS CLI** configured with credentials
4. **KMS Key** with ENCRYPT_DECRYPT usage (can use `alias/aws/s3`)
5. **AWS Organization ID** (if using AWS Organizations)
6. **IROCO2 API credentials** and endpoints

## Quick Start

1. **Clone or copy this example**:
   ```bash
   cp -r examples/basic my-iroco2-deployment
   cd my-iroco2-deployment
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual values
   ```

3. **Build Lambda artifacts** (from the module root):
   ```bash
   cd ../../
   zip -r cur-scanner.zip package/
   zip -r helper-scripts.zip layers/
   cd examples/basic/
   ```

4. **Deploy**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `kms_key_id` | KMS key for encryption | `"alias/aws/s3"` |
| `aws_org_id` | AWS Organization ID | `"o-1234567890"` |
| `iroco2_api_endpoint` | IROCO2 API URL | `"https://api.iroco2.com"` |
| `iroco2_gateway_endpoint` | IROCO2 Gateway URL | `"https://gateway.iroco2.com"` |
| `iroco2_api_key` | IROCO2 API key | `"your-secret-key"` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `"eu-west-3"` |
| `project_name` | Project name prefix | `"iroco2"` |
| `environment` | Environment name | `"dev"` |
| `lambda_timeout` | Function timeout (seconds) | `900` |
| `lambda_memory_size` | Function memory (MB) | `512` |

## What This Example Creates

- **S3 Bucket**: For Lambda artifacts (automatically named)
- **S3 Bucket**: For CUR output (automatically named)
- **Lambda Function**: CUR processing function
- **Lambda Layer**: Helper scripts layer
- **IAM Role**: With minimal required permissions
- **CloudWatch Log Group**: For monitoring
- **S3 Event Notifications**: Automatic triggering

## Usage

After deployment, upload CUR files (`.parquet` or `.csv.zip`) to the CUR output bucket:

```bash
aws s3 cp my-cur-file.parquet s3://$(terraform output -raw s3_bucket_name)/
```

The Lambda function will automatically process the file and send data to IROCO2.

## Monitoring

View logs in CloudWatch:

```bash
aws logs tail $(terraform output -raw cloudwatch_log_group) --follow
```

## Cleanup

```bash
terraform destroy
```

## Customization

This example can be customized by:

1. **Using existing S3 buckets** instead of creating new ones
2. **Modifying Lambda configuration** (memory, timeout, environment variables)
3. **Adding additional tags** or resource naming conventions
4. **Integrating with existing VPC** or security groups

## Troubleshooting

### Common Issues

1. **KMS Key Permissions**: Ensure the KMS key allows CloudWatch Logs service
2. **S3 Bucket Names**: Must be globally unique
3. **Lambda Artifacts**: Ensure ZIP files exist before deployment
4. **API Credentials**: Verify IROCO2 endpoints and API key

### Getting Help

- Check the main module [README](../../README.md) for detailed documentation
- Review CloudWatch logs for runtime errors
- Validate your terraform.tfvars configuration
