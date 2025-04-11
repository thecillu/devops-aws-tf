resource "aws_acm_certificate" "acm-certificate" {
  domain_name       = "alb.${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
  validation_method = "DNS"

  validation_option {
    domain_name       = "alb.${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
    validation_domain = "${data.aws_route53_zone.provided-zone.name}"
  }
}

resource "aws_route53_record" "route53-record" {
  for_each = {
    for dvo in aws_acm_certificate.acm-certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.provided-zone.zone_id
}

resource "aws_acm_certificate" "cdn-acm-certificate" {
  provider = "aws.us-east-1"
  domain_name       = "${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
  validation_method = "DNS"

  validation_option {
    domain_name       = "${var.service_name}.${var.environment}.${data.aws_route53_zone.provided-zone.name}"
    validation_domain = "${data.aws_route53_zone.provided-zone.name}"
  }
}

resource "aws_route53_record" "cdn-route53-record" {
  for_each = {
    for dvo in aws_acm_certificate.cdn-acm-certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
      provider = "aws.us-east-1"
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.provided-zone.zone_id
}