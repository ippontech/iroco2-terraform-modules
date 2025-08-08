variable "instance_type" {
  default     = "t3a.nano"
  type        = string
  description = "The instance type for the bastion."
}

variable "bastion_volume_size" {
  type        = number
  description = "disk volume size for asg bastion instances"
  default     = 10
}

variable "down_recurrence" {
  type        = string
  description = "Down Recurrence"
}
