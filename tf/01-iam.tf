## instance role
data "aws_iam_policy_document" "app" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${local.appid}-app"
  description        = "${local.appid} instance role"
  assume_role_policy = data.aws_iam_policy_document.app.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.appid}-app"
  role = aws_iam_role.app.name
}

## ecs task execution role
data "aws_iam_policy_document" "ecs-task" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "loggroup" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "ecs-task" {
  name               = "${local.appid}-ecs-task"
  description        = "${local.appid} ecs task execution role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task.json
}

resource "aws_iam_role_policy_attachment" "ecs-task" {
  role       = aws_iam_role.ecs-task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "loggroup" {
  name   = "${local.appid}-ecs-task-loggroup"
  role   = aws_iam_role.ecs-task.name
  policy = data.aws_iam_policy_document.loggroup.json
}
