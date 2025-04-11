/*
  This creates an Application Load Balancer (ALB) with a target group and listener rules.
  It also includes HTTPS configuration and Route 53 DNS records for the ALB.
*/

resource "aws_alb" "alb" {
  name            = "${var.service_name}-alb"
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.alb-security-group.id]

  #### TOOD rendere opzionale
  access_logs {
      bucket  = aws_s3_bucket.bucket_logs.id
      prefix  = "alb"
      enabled = var.alb_logging_enabled
  }
  tags = {
    Name        = "${var.service_name}-alb"
    Environment = var.environment
  }
}

resource "aws_alb_target_group" "alb-target-group" {
  name        = "${var.service_name}-alb-target-group"
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
  protocol           = "HTTP"
  port               = 80

  default_action {
    #type = "forward"
    #target_group_arn = aws_alb_target_group.alb-target-group.arn

    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "403"
    }

    #type = "redirect"
    #redirect {
    #  port        = "443"
    #  protocol    = "HTTPS"
    #  status_code = "HTTP_301"
    #}
    
  }
}


resource "aws_lb_listener_rule" "alb-listener-http-cdn-header-rule" {
  listener_arn = aws_alb_listener.alb-listener-http.arn
  priority     = 100
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }

  condition {
    http_header {
      http_header_name = "x-cdn-secret"
      values          = [var.cdn_secret_header]
    }
  }
}


## ENABLE HTTPS
/*
resource "aws_alb_listener" "alb-listener-https" {
load_balancer_arn = aws_alb.alb.arn
  protocol           = "HTTPS"
  port               = 443
  certificate_arn = aws_acm_certificate.cert.arn
  
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
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }

  condition {
    http_header {
      http_header_name = "x-cdn-secret"
      values          = [var.cdn_secret_header]
    }
  }
}


//TODO provided
resource "aws_route53_zone" "route53-zone" {
  name = "${var.service_name}.${var.environment}.scalapay.com"

  tags = {
    Name        = "${var.service_name}-route53-zone"
    Environment = var.environment
  }
}

resource "aws_route53_record" "alb_alias_record" {
  zone_id = aws_route53_zone.route53-zone.zone_id
  name    = "alb.${var.service_name}.${var.environment}.scalapay.com"
  ttl     = 300
  type    = "CNAME"
  records = [aws_alb.alb.dns_name]
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "alb.${var.service_name}.${var.environment}.scalapay.com"
  validation_method = "DNS"

  validation_option {
    domain_name       = "alb.${var.service_name}.${var.environment}.scalapay.com"
    validation_domain = "scalapay.com"
  }
}

resource "aws_route53_record" "example" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.route53-zone.zone_id
}
*/