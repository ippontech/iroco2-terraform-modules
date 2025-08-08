resource "aws_acm_certificate" "cert_docs" {
  provider          = aws.cloudfront
  domain_name       = "docs.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert-cname-docs" {
  provider = aws.cloudfront
  for_each = {
    for dvo in aws_acm_certificate.cert_docs.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}


resource "aws_acm_certificate_validation" "example-validation-docs" {
  provider                = aws.cloudfront
  certificate_arn         = aws_acm_certificate.cert_docs.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-cname-docs : record.fqdn]
}

resource "aws_route53_record" "exampleDomain-a-docs" {
  provider = aws.cloudfront
  zone_id  = data.aws_route53_zone.selected.zone_id
  name     = "docs.${var.domain_name}"
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.docs_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.docs_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}