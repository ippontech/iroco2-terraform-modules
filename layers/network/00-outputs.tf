output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "database_subnets_ids" {
  value = module.vpc.database_subnets
}

output "security_group_ids" {
  value = { for s in aws_security_group.this : s.name => s.id }
}

output "alb_listener_https_arn" {
  value = aws_lb_listener.public_https.arn
}
