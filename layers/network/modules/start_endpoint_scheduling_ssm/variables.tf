# Common
variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
}

variable "SecurityGroupId" {
  type        = string
  description = "The id of the security group"
}

variable "SubnetIds" {
  type        = list(any)
  description = "List of subnet ids"
}

variable "vpc_id" {
  type        = string
  description = "The id of the VPC to use."
}

variable "RouteTableIds" {
  type        = list(string)
  description = "The list of route table Id"
}

# SSM

variable "tag_autoshutdown" {
  type        = string
  description = "Describe how the ressources is managed: True if a ssm document is applied to start and stop the ressource"
}

variable "endpoint" {
  type        = any
  description = "The endpoint we want to automate"
}

variable "ssm_document" {
  description = "SSM document's name to apply"
  type        = string
}

variable "working_days" {
  type        = list(string)
  description = "The list of working days"
}
