resource "aws_alb" "alb" {
  name            = "${var.service_name}-alb"
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.alb-security-group.id]

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
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb-listener-https" {
load_balancer_arn = aws_alb.alb.arn
  protocol           = "HTTPS"
  port               = 443
  certificate_arn = aws_acm_certificate.example.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb-target-group.arn
  }

}

# Create a self-signed certificate using the TLS provider
 resource "tls_private_key" "alb-cert-private-key" {
        algorithm = "RSA"
        rsa_bits = 2048    
  }

  resource "tls_self_signed_cert" "alb-self-signed-cert" {
        private_key_pem = tls_private_key.alb-cert-private-key.private_key_pem
        subject {
          common_name = "alb.example.${var.environment}.scalapay.com"
        }
        validity_period_hours = 8760
        allowed_uses = [
          "key_encipherment",
          "digital_signature",
          "server_auth",
        ]
        dns_names = ["alb.example.${var.environment}.scalapay.com"]
  }


resource "aws_acm_certificate" "example" {
  private_key      = tls_private_key.alb-cert-private-key.private_key_pem
  certificate_body = tls_self_signed_cert.alb-self-signed-cert.cert_pem
}