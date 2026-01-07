locals {
  domain_name = "${var.subdomain_name}.${var.zone_name}"

  task_environment = [
    for k, v in var.task_container_environment : {
      name  = k
      value = v
    }
  ]
  task_secrets_arn = [
    for k, v in var.task_container_secrets_arn : {
      name      = k
      valueFrom = v
    }
  ]
  task_secrets_arn_with_key = [
    for k, v in var.task_container_secrets_arn_with_key : {
      name      = k
      valueFrom = "${v.arn}:${v.key}::"
    }
  ]
}
