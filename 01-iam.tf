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

resource "aws_iam_instance_profile" "app" {
  name = "${local.appid}-app"
  role = aws_iam_role.app.name
}
