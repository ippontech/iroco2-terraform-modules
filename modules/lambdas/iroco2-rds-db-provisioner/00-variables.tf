variable "databases" {
  type        = list(string)
  description = "List of database names to provision"
  default     = []
}

variable "schemas" {
  type = list(object({
    database = string
    name     = string
    owner    = string
  }))
  description = "List of schemas to create"
  default     = []
}

variable "roles" {
  type = list(object({
    name = string
  }))
  description = "List of roles to create"
  default     = []
}

variable "users" {
  type = list(object({
    name         = string
    password     = optional(string)
    password_arn = optional(string)
    roles        = list(string)
  }))
  description = "Users to create and assign roles"
  default     = []
}

variable "grants" {
  type = list(object({
    object_type = string
    grant_to    = string
    database    = string
    privileges  = list(string)
    target      = string
  }))
  description = "Database-level grants"
  default     = []
}

variable "auto_grants" {
  type = list(object({
    object_type = string
    created_by  = string
    grant_to    = string
    privileges  = list(string)
    schema      = string
    database    = string
  }))
  description = "Auto-grants (ALTER DEFAULT PRIVILEGES)"
  default     = []
}


variable "lambda_function_name" {
  type = string
}

variable "lambda_iam_role_arn" {
  type    = string
  default = ""
}

variable "lambda_subnet_ids" {
  type        = list(string)
  description = "IDs of the subnets on which the lambda will run"
}

variable "lambda_security_group_id" {
  type        = string
  description = "ID of the security group which will be used by the lambda"
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_log_level" {
  type    = string
  default = "info"
}

variable "lambda_force_invoke" {
  type    = bool
  default = false
}

variable "rds_secret_arn" {
  description = "ARN of the RDS master password secret in Secrets Manager"
  type        = string
}

variable "rds_endpoint" {
  description = "The hostname or endpoint of the RDS database"
  type        = string
}

variable "rds_db_port" {
  description = "The port number the RDS database is listening on"
  type        = number
  default     = 5432
}

variable "rds_default_db_name" {
  description = "The default database name to connect to in RDS"
  type        = string
}

variable "rds_ssl_mode" {
  description = "SSL mode for RDS connection (e.g., disable, require, verify-ca)"
  type        = string
  default     = "require"
}

variable "rds_db_driver" {
  description = "The database driver to use (e.g., postgres, mysql)"
  type        = string
}

variable "rds_db_user" {
  description = "The database user which will be used for connection to rds_default_db_name"
  type        = string
}
