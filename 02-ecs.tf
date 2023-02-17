resource "aws_ecs_cluster" "app" {
  name = "${local.appid}-app"
}

resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name       = aws_ecs_cluster.app.name
  capacity_providers = [aws_ecs_capacity_provider.app.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.app.name
  }
}

resource "aws_ecs_capacity_provider" "app" {
  name = "${local.appid}-app"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.app.arn
  }
}

resource "aws_autoscaling_group" "app" {
  name                 = "${local.appid}-app"
  availability_zones   = ["ap-northeast-1a"]
  max_size             = 0
  min_size             = 0
  desired_capacity     = 0
  health_check_type    = "ELB"
  force_delete         = true
  launch_configuration = aws_launch_configuration.app.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
}

resource "aws_security_group" "app" {
  # name        = "${local.appid}-app"
  description = "${local.appid} security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 123
    to_port     = 123
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "app" {
  image_id      = local.image_id
  instance_type = local.instance_type

  key_name             = "home"
  iam_instance_profile = aws_iam_instance_profile.app.name
  security_groups      = [aws_security_group.app.name]

  user_data = <<EOT
  #!/bin/bash
  echo "ECS_CLUSTER=${local.appid}-app" >> /etc/ecs/ecs.config
  EOT

  lifecycle {
    create_before_destroy = true
  }
}


