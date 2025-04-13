/*
 * This file creates Route 53 records for the ALB and CloudFront distribution.
*/
data "aws_route53_zone" "provided-zone" {
  zone_id      = var.zone_id
  private_zone = false
}

resource "aws_route53_record" "alb-alias-record" {
  zone_id = data.aws_route53_zone.provided-zone.zone_id
  name    = "alb.${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
  ttl     = 300
  type    = "CNAME"
  records = [aws_alb.alb.dns_name]
}

resource "aws_route53_record" "cdn-alias-record" {
  zone_id = data.aws_route53_zone.provided-zone.zone_id
  name    = "${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
  ttl     = 300
  type    = "CNAME"
  records = [aws_cloudfront_distribution.cdn_distribution.domain_name]
}

