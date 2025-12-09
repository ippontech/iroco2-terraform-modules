data "aws_route53_zone" "main" {
  name = var.zone_name
}

data "aws_region" "this" {}
