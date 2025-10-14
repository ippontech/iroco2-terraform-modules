locals {
  # Common tags merged with user-provided tags
  tags = merge(var.common_tags, {
    ManagedBy = "Terraform"
    Module    = "iroco2-client-side-scanner"
  })

  # Lambda layer name
  layer_name = "helper-scripts"

  # S3 bucket notification events
  s3_notification_events = [
    "s3:ObjectCreated:*"
  ]

  # S3 object filters for Lambda triggers
  s3_object_filters = [
    {
      suffix = ".parquet"
    },
    {
      suffix = ".csv.gz"
    }
  ]
}

# Data sources
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
