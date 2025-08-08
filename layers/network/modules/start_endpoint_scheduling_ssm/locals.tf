locals {
  endpoint_ssm_parameter = {
    VpcId             = var.vpc_id
    SubnetIds         = var.endpoint.type == "Interface" ? var.SubnetIds : null
    ServiceName       = var.endpoint.service_name
    VpcEndpointType   = var.endpoint.type
    PrivateDnsEnabled = var.endpoint.type == "Interface" ? true : false
    SecurityGroupId   = var.endpoint.type == "Interface" ? [var.SecurityGroupId] : null
    RouteTableIds     = var.endpoint.type == "Gateway" ? var.RouteTableIds : null
    TagSpecifications = [
      {
        ResourceType = "vpc-endpoint"
        Tags = [
          {
            Key   = "Name"
            Value = var.endpoint.name_tag
          },
          {
            Key   = "namespace"
            Value = var.namespace
          },
          {
            Key   = "auto-shutdown"
            Value = var.tag_autoshutdown
          }
        ]
      }
    ]
  }
}
