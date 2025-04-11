resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {

}

resource "aws_cloudfront_distribution" "cdn_distribution" {

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

  enabled = true
  aliases                           = ["${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "${local.service_env_name}-origin"

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    #cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    acm_certificate_arn           = "${aws_acm_certificate.cdn-acm-certificate.arn}"
  }

  tags = {
    Name        = "${local.service_env_name}-cdn"
    Environment = var.environment
  }
}