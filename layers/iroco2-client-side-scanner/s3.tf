# S3 bucket for CUR output
resource "aws_s3_bucket" "cur_output" {
  bucket = var.cur_output_bucket_name

  tags = local.tags
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "cur_output" {
  bucket = aws_s3_bucket.cur_output.id
  versioning_configuration {
    status = "Suspended"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "cur_output" {
  bucket = aws_s3_bucket.cur_output.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "cur_output" {
  bucket = aws_s3_bucket.cur_output.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy
resource "aws_s3_bucket_policy" "cur_output" {
  bucket = aws_s3_bucket.cur_output.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.cur_output.arn,
          "${aws_s3_bucket.cur_output.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
          StringEquals = {
            "aws:PrincipalOrgId" = var.aws_org_id
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "bcm-data-exports.amazonaws.com",
            "billingreports.amazonaws.com"
          ]
        }
        Action = [
          "s3:GetBucketPolicy",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.cur_output_bucket_name}",
          "arn:aws:s3:::${var.cur_output_bucket_name}/*"
        ]
        Condition = {
          StringLike = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id,
            "aws:SourceArn" = [
              "arn:aws:bcm-data-exports:us-east-1:${data.aws_caller_identity.current.account_id}:export/*",
              "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*"
            ]
          }
        }
      },
      {
        Effect = "Deny"
        Principal = {
          AWS = aws_iam_role.lambda_execution.arn
        }
        NotAction = ["s3:GetObject", "s3:ListBucket"]
        Resource  = ["${aws_s3_bucket.cur_output.arn}/*", aws_s3_bucket.cur_output.arn]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.cur_output]
}

# S3 bucket notification
resource "aws_s3_bucket_notification" "cur_output" {
  bucket = aws_s3_bucket.cur_output.id

  dynamic "lambda_function" {
    for_each = local.s3_object_filters
    content {
      lambda_function_arn = aws_lambda_function.processing.arn
      events              = local.s3_notification_events
      filter_suffix       = lambda_function.value.suffix
    }
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
