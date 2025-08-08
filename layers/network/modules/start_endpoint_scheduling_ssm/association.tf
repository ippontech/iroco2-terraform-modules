resource "aws_ssm_association" "create_vpc_endpoints" {

  #we need to convert to a map first
  for_each = toset(var.working_days)

  apply_only_at_cron_interval = true

  name = var.ssm_document

  association_name = "CreateVpcEndpoint-${each.value}-${var.endpoint.name_tag}"

  schedule_expression = "cron(15 6 ? * ${each.value} *)" #GMT -> 8:15 AM in Paris

  parameters = {
    VpcEndpointList = jsonencode(local.endpoint_ssm_parameter)
  }

  automation_target_parameter_name = "VpcEndpointList"

  targets {
    key    = "ParameterValues"
    values = [jsonencode(local.endpoint_ssm_parameter)]
  }
}
