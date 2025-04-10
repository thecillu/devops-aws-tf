# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "alb-security-group" {
  name        = "${var.service_name}-alb-security-group"
  description = "Security group for ${var.service_name} alb"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
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