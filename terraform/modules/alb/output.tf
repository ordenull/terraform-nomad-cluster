output "security_group_id" {
  value = aws_security_group.main.id
}

output "https_listener_arn" {
  value = aws_alb_listener.https.arn
}

output "dns_name" {
  value = aws_alb.main.dns_name
}

output "zone_id" {
  value = aws_alb.main.zone_id
}