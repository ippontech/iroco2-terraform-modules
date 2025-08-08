provider "aws" {
  default_tags {
    tags = {
      namespace    = var.namespace
      project_type = var.project_type
      project      = var.project_name
      environment  = var.environment
    }
  }
}
