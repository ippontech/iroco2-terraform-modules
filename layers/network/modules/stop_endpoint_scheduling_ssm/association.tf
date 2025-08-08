resource "aws_ssm_association" "delete_vpc_endpoints" {

  for_each = toset(var.working_days)

  apply_only_at_cron_interval = true

  name = var.ssm_document

  association_name = "DeleteVpcEndpoint-${each.value}"

  schedule_expression = "cron(15 18 ? * ${each.value} *)" #GMT -> 8:15 PM in Paris

  parameters = {
    tagname = var.tag_autoshutdown
  }

  automation_target_parameter_name = "tagname"

  targets {
    key    = "ParameterValues"
    values = [var.tag_autoshutdown]
  }
}
