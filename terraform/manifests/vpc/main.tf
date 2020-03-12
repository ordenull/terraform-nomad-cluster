## VPC and Security Groups
#################################################################
module "main_vpc" {
  source              = "../../modules/vpc"
  prefix              = terraform.workspace
  tags                = var.tags[terraform.workspace]
  domain              = var.vpc[terraform.workspace]["domain"]
  vpc_cidr            = var.vpc[terraform.workspace]["vpc_cidr"]
  subnet_mask         = var.vpc[terraform.workspace]["subnet_mask"]
  trusted_cidr        = var.trusted_cidr

  # Disabled for cost reasons
  enable_private_link_s3     = true
  enable_private_link_docker = false
  enable_nat_gateways        = false
  enable_private_ipv6_egress = true
}

## DNS delegation
#################################################################
locals {
  # Find the Top Level Domain name of the VPC subdomain
  tld_root = element(split(".", var.vpc[terraform.workspace]["domain"]), length(split(".", var.vpc[terraform.workspace]["domain"])) - 1)
  tld_sub = element(split(".", var.vpc[terraform.workspace]["domain"]), length(split(".", var.vpc[terraform.workspace]["domain"])) - 2)
  tld     = "${local.tld_sub}.${local.tld_root}"
}

# If this resource is not found, it means that the TLD for the VPC subdomain is hosted elsewhere
# To proceed, you will need to comment this out and set up the delegation manually.
data "aws_route53_zone" "tld" {
  name         = "${local.tld}."
  private_zone = false
}

resource "aws_route53_record" "delegation" {
  zone_id = data.aws_route53_zone.tld.zone_id
  name    = "${var.vpc[terraform.workspace]["domain"]}."
  type    = "NS"
  ttl     = "300"
  records = module.main_vpc.route53_zone_public_ns
}
