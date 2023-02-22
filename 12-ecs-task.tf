resource "aws_ecs_task_definition" "app" {
  # family = local.app_id
  family = "nginx-arm64-2"
  memory = 128
#   cpu    = 256

  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      "name" : "nginx",
      "image" : "arm64v8/nginx",
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80,
        }
      ],
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/nginx-arm64",
          "awslogs-region" : "ap-northeast-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}
