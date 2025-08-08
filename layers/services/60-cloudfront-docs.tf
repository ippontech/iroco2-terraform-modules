resource "aws_cloudfront_origin_access_control" "docs" {
  provider                          = aws.cloudfront
  name                              = "${var.namespace}-docs"
  description                       = "CloudFront docs access policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "docs_distribution" {
  provider = aws.cloudfront
  origin {
    domain_name              = aws_s3_bucket.docs_bucket.bucket_regional_domain_name
    origin_id                = "S3-docs"
    origin_access_control_id = aws_cloudfront_origin_access_control.docs.id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = ["docs.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-docs"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Handle SPA routing
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.example-validation-docs.certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.namespace}-docs"
  }
}

resource "aws_s3_bucket" "docs_bucket" {
  provider = aws.cloudfront
  bucket   = "${var.namespace}-cloudfront-docs-${var.environment}-bucket"
}

resource "aws_s3_bucket_cors_configuration" "docs" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.docs_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "docs_bucket_policy" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.docs_bucket.bucket
  policy   = data.aws_iam_policy_document.docs_bucket_policy.json
}

data "aws_iam_policy_document" "docs_bucket_policy" {
  provider = aws.cloudfront
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.docs_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.docs_distribution.arn]
    }
  }
}
