/*
 * This file creates an Application Load Balancer (ALB) with a target group and listener rules.
 * It also includes HTTPS configuration and Route 53 DNS records for the ALB.
*/

resource "aws_alb" "alb" {
  name            = "${local.service_env_name}-alb"
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.alb-security-group.id]

  access_logs {
    bucket  = aws_s3_bucket.bucket_logs.id
    prefix  = "alb"
    enabled = var.alb_logging_enabled
  }
  tags = {
    Name        = "${local.service_env_name}-alb"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "alb-target-group" {
  name        = "${local.service_env_name}-alb-target-group"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = aws_alb.alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb-listener-https" {
  load_balancer_arn = aws_alb.alb.arn
  protocol          = "HTTPS"
  port              = 443
  certificate_arn   = aws_acm_certificate.acm-certificate.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "alb-listener-https-cdn-header-rule" {
  listener_arn = aws_alb_listener.alb-listener-https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }

  condition {
    http_header {
      http_header_name = "x-cdn-secret"
      values           = [var.cdn_secret_header]
    }
  }
}