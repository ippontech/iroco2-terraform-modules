# Copyright 2025 Ippon Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

# Frontend CloudFront distribution
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  provider                          = aws.cloudfront
  name                              = "${var.namespace}-${var.environment}-frontend"
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
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [local.domain_name]

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
    acm_certificate_arn = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.namespace}-${var.environment}-s3-cloudfront"
    project     = var.project_name
  }
}

resource "aws_s3_bucket" "bucket" {
  provider = aws.cloudfront
  bucket   = "${var.namespace}-cloudfront-${var.environment}-bucket"

  tags_all = {
    project = var.project_name
  }
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.bucket.bucket
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  provider = aws.cloudfront
  bucket   = aws_s3_bucket.bucket.bucket
  policy   = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
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

# Docs CloudFront distribution
resource "aws_cloudfront_origin_access_control" "docs" {
  provider                          = aws.cloudfront
  name                              = "${var.namespace}-${var.environment}-docs"
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

  aliases = ["docs.${local.domain_name}"]

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
    acm_certificate_arn = aws_acm_certificate_validation.example_validation_docs.certificate_arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Environment = var.environment
    Name        = "${var.namespace}-${var.environment}-docs"
    project     = var.project_name
  }
}

resource "aws_s3_bucket" "docs_bucket" {
  provider = aws.cloudfront
  bucket   = "${var.namespace}-cloudfront-docs-${var.environment}-bucket"

  tags_all = {
    project = var.project_name
  }
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
