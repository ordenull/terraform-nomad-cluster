output "vpc_public_subnets" {
  value = module.main_vpc.public_subnet_ids
}

output "vpc_private_subnets" {
  value = module.main_vpc.private_subnet_ids
}


output "vpc_public_main_sg" {
  value = module.main_vpc.public_main_sg_id
}

output "vpc_private_main_sg" {
  value = module.main_vpc.private_main_sg_id
}


output "vpc_public_zone_id" {
  value = module.main_vpc.route53_zone_public_id
}

output "vpc_private_zone_id" {
  value = module.main_vpc.route53_zone_private_id
}

output "vpc_acm_wildcard_arn" {
  value = module.ssl_wildcard.cert_arn
}