variable "rds_instance_class" {
  type        = string
  description = "The instance class to use for the RDS."
}

variable "rds_database_engine" {
  type        = string
  description = "The engine to use for the RDS."
}

variable "rds_database_engine_version" {
  type        = string
  description = "The engine's version to use for the RDS."
}

variable "rds_allocated_storage" {
  type        = string
  description = "The size allocated for the storage."
}

variable "rds_backup_retention_period" {
  type        = string
  description = "The time a backup will be available."
}

variable "rds_is_multi_az" {
  type        = bool
  description = "Set to true if the RDS should be on multiple az."
}

variable "rds_database_port" {
  type        = number
  description = "The port to use for the RDS."
}

variable "rds_database_name" {
  type        = string
  description = "RDS's name"
}
