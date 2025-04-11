/*
  It creates the security groups for the ALB and ECS cluster.
  The ALB security group allows traffic from CloudFront and the ECS security group allows traffic from the ALB only.
*/

data "aws_ec2_managed_prefix_list" "cloudfront-origin-prefix-list" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.global.cloudfront.origin-facing"]
  }
}

resource "aws_security_group" "alb-security-group" {
  name        = "${var.service_name}-alb-security-group"
  description = "Security group for ${var.service_name} alb"
  vpc_id      = aws_vpc.vpc.id


  /*dynamic "ingress" {
    for_each = data.aws_ec2_managed_prefix_list.cloudfront-origin-prefix-list.entries
    content {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = [ingress.value["cidr"]]
    }
  }*/

  dynamic "ingress" {
    for_each = data.aws_ec2_managed_prefix_list.cloudfront-origin-prefix-list.entries
    content {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = [ingress.value["cidr"]]
    }
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service_name}-alb-security-group"
    Environment = var.environment
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs-security-group" {
  name        = "${var.service_name}-ecs-security-group"
  description = "Allow inbound access from the ALB only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.alb-security-group.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.service_name}-ecs-security-group"
    Environment = var.environment
  }
}