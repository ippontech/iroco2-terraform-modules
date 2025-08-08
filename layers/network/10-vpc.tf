data "aws_region" "this" {}

variable "cidr" {
  description = "The IPv4 CIDR block for the VPC."
  type        = string
}

variable "azs" {
  type = object({
    eu-west-3 = list(string)
  })
  description = "A list of availability zones names or ids in the region"
  default = {
    eu-west-3 = ["eu-west-3a", "eu-west-3b"],
  }
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}
variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.namespace}-${var.environment}"

  cidr = var.cidr

  azs              = var.azs[data.aws_region.this.name]
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  vpc_tags = {
    Name = "${var.namespace}-${var.environment}-vpc"
  }
}
