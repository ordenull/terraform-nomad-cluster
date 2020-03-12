## External Application Load Balancer
#################################################################
module "alb_main_ext" {
  source            = "../../modules/alb"
  prefix            = terraform.workspace
  name              = "nomad-main-ext"
  tags              = var.tags[terraform.workspace]
  description       = "Default ALB to bunch up all nomad ingress"

  vpc_subnets       = local.vpc_public_subnets
  vpc_addon_sgs     = []

  alb_allowed_cidr4 = ["0.0.0.0/0"]
  alb_allowed_cidr6 = ["::/0"]

  ssl_cert_arn      = local.vpc_acm_wildcard_arn
}