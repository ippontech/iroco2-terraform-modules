# Copyright 2025 Ippon Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

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
    "${var.namespace}-${var.environment}-irocalc-backend"
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
