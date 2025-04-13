/*
 * This file creates a CloudFront distribution for the application.
 * It uses an Application Load Balancer (ALB) as the origin.
 * The traffic between the client and CloudFront is encrypted using HTTPS.
 * The traffic between CloudFront and the ALB is encrypted using HTTPS.
*/
resource "aws_cloudfront_distribution" "cdn_distribution" {
  enabled = true
  aliases = ["${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"]


  origin {
    domain_name = "alb.${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
    origin_id   = "${local.service_env_name}-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
      name  = "x-cdn-secret"
      value = var.cdn_secret_header
    }
  }

  dynamic "logging_config" {
    for_each = var.cdn_logging_enabled == true ? ["enabled"] : []
    content {
      include_cookies = false
      bucket          = aws_s3_bucket.bucket_logs.bucket_domain_name
      prefix          = "cdn/"
    }

  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = "${local.service_env_name}-origin"
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = aws_acm_certificate.cdn-acm-certificate.arn
  }

  tags = {
    Name        = "${local.service_env_name}-cdn"
    Environment = var.environment
  }
}