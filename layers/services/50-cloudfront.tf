resource "aws_cloudfront_origin_access_control" "example" {
  provider                          = aws.cloudfront
  name                              = "${var.namespace}-frontend"
  description                       = "cloudfront irocal access policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  provider = aws.cloudfront
  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id                = "S3-bucket"
    origin_access_control_id = aws_cloudfront_origin_access_control.example.id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-bucket"

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

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.example-validation.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_s3_bucket" "bucket" {
  provider = aws.cloudfront
  bucket   = "${var.namespace}-cloudfront-${var.environment}-bucket"
}

resource "aws_s3_bucket_cors_configuration" "example" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.bucket.bucket
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.bucket.bucket
  policy   = data.aws_iam_policy_document.example.json
}

data "aws_iam_policy_document" "example" {
  provider = aws.cloudfront
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}