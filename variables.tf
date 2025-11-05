variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "domain_name" {
  type        = string
  description = "The domain name associated to this environment"
}

variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  type        = list(string)
  description = "The private subnets for the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type        = list(string)
  description = "The public subnets for the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "database_subnets" {
  type        = list(string)
  description = "The database subnets for the VPC"
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}