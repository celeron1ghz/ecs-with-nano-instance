locals {
  appid = "acceptessa2"

  // getting latest amazonlinux2 ami id
  // aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --query "Parameters[].[Value, LastModifiedDate, Name]" --output text

  // getting ecs optimized latest amazonlinux2 ami id
  // aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id --query "Parameters[].[Value, LastModifiedDate, Name]" --output text
  image_id      = "ami-02378d43835d39ff4"
  instance_type = "t4g.nano"
}
