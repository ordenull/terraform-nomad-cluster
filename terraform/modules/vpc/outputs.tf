output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_iv4" {
  value = aws_vpc.main.cidr_block
}

output "vpc_cidr_ipv6" {
  value = aws_vpc.main.ipv6_cidr_block
}


output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "public_main_sg_id" {
  value = aws_security_group.main_public.id
}


output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "private_route_table_id" {
  value = aws_route_table.private.*.id
}

output "private_main_sg_id" {
  value = aws_security_group.main_private.id
}


output "route53_zone_public_id" {
  value = aws_route53_zone.public.id
}

output "route53_zone_public_ns" {
  value = aws_route53_zone.public.name_servers
}


output "route53_zone_private_id" {
  value = aws_route53_zone.private.id
}

output "route53_zone_private_ns" {
  value = aws_route53_zone.private.name_servers
}


output "route53_zone_reverse_id" {
  value = aws_route53_zone.reverse.id
}

output "route53_zone_reverse_ns" {
  value = aws_route53_zone.reverse.name_servers
}