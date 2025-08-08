resource "aws_ssm_parameter" "cloudfront-bucket-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/CLOUDFRONT_BUCKET_ID")
  type  = "SecureString"
  value = aws_s3_bucket.bucket.id
}

resource "aws_ssm_parameter" "cloudfront-distribution-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/CLOUDFRONT_DISTRIBUTION_ID")
  type  = "SecureString"
  value = aws_cloudfront_distribution.s3_distribution.id
}