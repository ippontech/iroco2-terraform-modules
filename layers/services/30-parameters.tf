resource "aws_ssm_parameter" "parameters_list" {
  for_each = toset(var.parameters_list)

  name  = upper("/${var.namespace}/PARAMETERS/${each.value}")
  type  = "SecureString"
  value = "value_to_change"

  lifecycle {
    ignore_changes = [value]
  }
}
