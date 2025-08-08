resource "aws_ecs_cluster" "main" {
  name = "${var.namespace}-${var.environment}-cluster"

  setting {
    # Enable container insights only for production environment (in order to reduce the cost induced by the service)
    name  = "containerInsights"
    value = var.container_insight_setting_value
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [var.capacity_provider]
}
