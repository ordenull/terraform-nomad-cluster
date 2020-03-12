## ACM Managed General Purpose SSL Certificate
#################################################################
module "ssl_wildcard" {
  source                    = "../../modules/acm-ssl-cert"
  prefix                    = terraform.workspace
  name                      = "wildcard"
  tags                      = var.tags[terraform.workspace]
  domain                    = "*.${var.vpc[terraform.workspace]["domain"]}"
  validation_route53_zoneid = module.main_vpc.route53_zone_public_id
}