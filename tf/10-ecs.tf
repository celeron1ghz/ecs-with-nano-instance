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

# resource "aws_ecs_capacity_provider" "app" {
#   name = "${local.appid}-app"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn         = aws_autoscaling_group.app.arn
#     managed_termination_protection = "ENABLED"

#     managed_scaling {
#       # maximum_scaling_step_size = 1000
#       # minimum_scaling_step_size = 1
#       target_capacity = 100
#       status          = "ENABLED"
#     }
#   }
# }

resource "aws_autoscaling_group" "app1" {
  name               = "${local.appid}-app-a"
  availability_zones = ["ap-northeast-1a"]
  max_size           = 1
  min_size           = 0
  desired_capacity   = 0
  health_check_type  = "ELB"
  force_delete       = true

  launch_template {
    id      = aws_launch_template.app1.id
    version = "$Latest"
  }

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

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_autoscaling_group" "app2" {
  name               = "${local.appid}-app-b"
  availability_zones = ["ap-northeast-1a"]
  max_size           = 1
  min_size           = 0
  desired_capacity   = 0
  health_check_type  = "ELB"
  force_delete       = true

  launch_template {
    id      = aws_launch_template.app2.id
    version = "$Latest"
  }

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

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}

resource "aws_launch_template" "app1" {
  image_id               = local.image_id
  instance_type          = local.instance_type
  key_name               = "home"
  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  user_data = base64encode(<<EOT
  #!/bin/bash
  echo "ECS_CLUSTER=${local.appid}-app-a" >> /etc/ecs/ecs.config
  EOT
  )
}

resource "aws_launch_template" "app2" {
  image_id               = local.image_id
  instance_type          = local.instance_type
  key_name               = "home"
  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  user_data = base64encode(<<EOT
  #!/bin/bash
  echo "ECS_CLUSTER=${local.appid}-app-b" >> /etc/ecs/ecs.config
  EOT
  )
}

resource "aws_security_group" "app" {
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
