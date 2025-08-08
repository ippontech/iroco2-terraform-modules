locals {
  lifecycle_policy = jsonencode({
    "rules" = [
      {
        "rulePriority" = 1
        "description"  = "Expire untagged images older than 1 day"
        "selection" = {
          "tagStatus"   = "untagged"
          "countType"   = "sinceImagePushed"
          "countUnit"   = "days"
          "countNumber" = 1
        }
        "action" = {
          "type" = "expire"
        }
      },
      {
        "rulePriority" = 2
        "description"  = "Expire main images when count is more than 3"
        "selection" = {
          "tagStatus"     = "tagged"
          "tagPrefixList" = ["main-", "develop-"]
          "countType"     = "imageCountMoreThan"
          "countNumber"   = 3
        }
        "action" = {
          "type" = "expire"
        }
      }
    ]
  })

  repositories = [
    "irocalc-backend"
  ]
}

resource "aws_ecr_repository" "repository" {
  for_each = toset(local.repositories)
  name     = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = each.value
  }
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  for_each = aws_ecr_repository.repository

  repository = each.value.name
  policy     = local.lifecycle_policy
}
