resource "aws_ecs_cluster" "app1" {
  name = "${local.appid}-app-a"
}

resource "aws_ecs_cluster" "app2" {
  name = "${local.appid}-app-b"
}

# resource "aws_ecs_cluster_capacity_providers" "app" {
#   cluster_name       = aws_ecs_cluster.app.name
#   capacity_providers = [aws_ecs_capacity_provider.app.name]

#   default_capacity_provider_strategy {
#     base              = 1
#     weight            = 100
#     capacity_provider = aws_ecs_capacity_provider.app.name
#   }
# }
