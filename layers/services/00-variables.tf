##################### METADATA #####################
variable "namespace" {
  type        = string
  description = "The namespace in which the project is."
  default     = "iroco2"
}

variable "environment" {
  type        = string
  description = "The name of the environment we are deploying to"
}

variable "project_name" {
  type        = string
  description = "Project's name"
  default     = "services"
}

variable "project_type" {
  type        = string
  description = "The type of project."
  default     = "infrastructure"
}

variable "domain_name" {
  type        = string
  description = "The domain name associated to this environment"
}
