locals {
  appid = "acceptessa2"

  // getting latest amazonlinux2 ami id
  // aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query "Parameters[].[Value, LastModifiedDate, Name]" --output text

  // getting arm64 ecs optimized latest amazonlinux2 ami id
  // aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/arm64/recommended/image_id --query "Parameters[].[Value, LastModifiedDate, Name]" --output text
  image_id      = "ami-000f45a90a4044e1f"
  instance_type = "t4g.micro"
}

# terraform {
#   required_version = ">= 0.9.0"

#   backend "s3" {
#     bucket = "xxxxxx"
#     key    = "xxxxxx.tfstate"
#     region = "ap-northeast-1"
#   }
# }
