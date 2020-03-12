output "server_security_group_id" {
  value = aws_security_group.server.id
}

output "server_iam_role_arn" {
  value = aws_iam_role.server.arn
}

output "server_asg_name" {
  value = aws_autoscaling_group.server.name
}