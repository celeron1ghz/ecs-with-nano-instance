resource "aws_ecr_repository" "foo" {
  name                 = "${local.appid}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
