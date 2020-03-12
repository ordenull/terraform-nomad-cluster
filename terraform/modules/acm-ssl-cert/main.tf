## SSL Certificate
#################################################################
resource "aws_acm_certificate" "main" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-${var.name}",
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

## DNS Validation
#################################################################
resource "aws_route53_record" "validation" {
  name    = aws_acm_certificate.main.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.main.domain_validation_options[0].resource_record_type
  zone_id = var.validation_route53_zoneid
  records = [aws_acm_certificate.main.domain_validation_options[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}