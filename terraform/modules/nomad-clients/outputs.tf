output "client_security_group_id" {
  value = aws_security_group.client.id
}

output "client_iam_role_arn" {
  value = aws_iam_role.client.arn
}

output "client_asg_name" {
  value = aws_autoscaling_group.client.name
}