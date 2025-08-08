# SSM

variable "tag_autoshutdown" {
  type        = string
  description = "Describe how the ressources is managed: True if a ssm document is applied to start and stop the ressource"
}

variable "ssm_document" {
  type        = string
  description = "SSM document's name to apply"
}

variable "working_days" {
  type        = list(string)
  description = "The list of working days"
}
