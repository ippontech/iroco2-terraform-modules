resource "aws_ssm_parameter" "docs-cloudfront-bucket-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/DOCUMENTATION_CLOUDFRONT_BUCKET_ID")
  type  = "SecureString"
  value = aws_s3_bucket.docs_bucket.id
}

resource "aws_ssm_parameter" "docs-cloudfront-distribution-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/DOCUMENTATION_CLOUDFRONT_DISTRIBUTION_ID")
  type  = "SecureString"
  value = aws_cloudfront_distribution.docs_distribution.id
}