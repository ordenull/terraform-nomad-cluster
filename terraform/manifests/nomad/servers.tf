## Config
#################################################################
locals {
  nomad_port_http = 4646
  consul_port_http = 8500
}

## Nomad Servers
#################################################################
module "nomad_servers" {
  source                = "../../modules/nomad-servers"
  prefix                = terraform.workspace
  cluster               = "nomad"
  name                  = "server"
  tags                  = var.tags[terraform.workspace]

  vpc_subnets           = local.vpc_public_subnets
  vpc_public_ip         = true
  vpc_addon_sgs         = [local.vpc_public_main_sg]

  asg_capacity_min      = 0
  asg_capacity_max      = 7
  asg_capacity_default  = 3
  asg_health_check_type = "EC2"

  instance_key          = aws_key_pair.admin.key_name
  instance_type         = "t3.nano"
  instance_ami          = data.aws_ami.base_ami.id

  volume_root_size      = 20

  allowed_client_sgs    = [
    module.nomad_clients_frontend.client_security_group_id
  ]

  # Harden the install
  protect_aws_metadata  = true

  # Server options
  nomad_port_http       = local.nomad_port_http
  consul_port_http      = local.consul_port_http
  node_gc_threshold     = "5m"
  job_gc_threshold      = "5m"
}

## Nomad Dashboard
#################################################################
# Allow trusted CIDRs to connect to the HTTP interface
resource "aws_security_group_rule" "nomad_servers_nomad_dashboard_trusted" {
  protocol                 = "tcp"
  security_group_id        = module.nomad_servers.server_security_group_id
  cidr_blocks              = var.trusted_cidr
  from_port                = local.nomad_port_http
  to_port                  = local.nomad_port_http
  type                     = "ingress"
  description              = "TF: Nomad Trusted HTTP"
}

## Nomad ALB rule to connect to the dashboard via the ALB
module "nomad_server_nomad_dashboard" {
  source              = "../../modules/alb-instance-target"
  prefix              = terraform.workspace
  name                = "nomad-dashboard"
  tags                = var.tags[terraform.workspace]

  vpc_subnets         = local.vpc_public_subnets

  listener_arn        = module.alb_main_ext.https_listener_arn
  listener_priority   = 110
  listener_rule_cidr  = var.trusted_cidr
  listener_rule_hosts = ["nomad.${var.vpc[terraform.workspace]["domain"]}"]
  listener_rule_paths = ["*"]
  instance_port       = local.nomad_port_http
  health_path         = "/v1/agent/health"
}

# Allow the ALB to connect to the HTTP interface
resource "aws_security_group_rule" "nomad_servers_nomad_dashboard_alb" {
  protocol                 = "tcp"
  security_group_id        = module.nomad_servers.server_security_group_id
  source_security_group_id = module.alb_main_ext.security_group_id
  from_port                = local.nomad_port_http
  to_port                  = local.nomad_port_http
  type                     = "ingress"
  description              = "TF: Nomad ALB"
}

# Automatically attach server instances to the dashboard target group
resource "aws_autoscaling_attachment" "external_alb_nomad" {
  autoscaling_group_name = module.nomad_servers.server_asg_name
  alb_target_group_arn   = module.nomad_server_nomad_dashboard.target_group_arn
}

# Create a nice DNS name to access the dashboard
resource "aws_route53_record" "nomad_servers" {
  zone_id = local.vpc_public_zone_id
  name    = "nomad.${var.vpc[terraform.workspace]["domain"]}"
  type    = "A"
  alias {
    name                   = module.alb_main_ext.dns_name
    zone_id                = module.alb_main_ext.zone_id
    evaluate_target_health = true
  }
}

## Consul Dashboard
#################################################################
# Allow trusted CIDRs to connect to the HTTP interface
resource "aws_security_group_rule" "nomad_servers_consul_dashboard_trusted" {
  protocol                 = "tcp"
  security_group_id        = module.nomad_servers.server_security_group_id
  cidr_blocks              = var.trusted_cidr
  from_port                = local.consul_port_http
  to_port                  = local.consul_port_http
  type                     = "ingress"
  description              = "TF: Nomad Trusted HTTP"
}

## Nomad ALB rule to connect to the dashboard via the ALB
module "nomad_server_consul_dashboard" {
  source              = "../../modules/alb-instance-target"
  prefix              = terraform.workspace
  name                = "consul-dashboard"
  tags                = var.tags[terraform.workspace]

  vpc_subnets         = local.vpc_public_subnets

  listener_arn        = module.alb_main_ext.https_listener_arn
  listener_priority   = 115
  listener_rule_cidr  = var.trusted_cidr
  listener_rule_hosts = ["consul.${var.vpc[terraform.workspace]["domain"]}"]
  listener_rule_paths = ["*"]
  instance_port       = local.consul_port_http
  health_path         = "/v1/status/leader"
}

# Allow the ALB to connect to the HTTP interface
resource "aws_security_group_rule" "nomad_servers_consul_dashboard_alb" {
  protocol                 = "tcp"
  security_group_id        = module.nomad_servers.server_security_group_id
  source_security_group_id = module.alb_main_ext.security_group_id
  from_port                = local.consul_port_http
  to_port                  = local.consul_port_http
  type                     = "ingress"
  description              = "TF: Nomad ALB"
}

# Automatically attach server instances to the dashboard target group
resource "aws_autoscaling_attachment" "external_alb_consul" {
  autoscaling_group_name = module.nomad_servers.server_asg_name
  alb_target_group_arn   = module.nomad_server_consul_dashboard.target_group_arn
}

# Create a nice DNS name to access the dashboard
resource "aws_route53_record" "consul_servers" {
  zone_id = local.vpc_public_zone_id
  name    = "consul.${var.vpc[terraform.workspace]["domain"]}"
  type    = "A"
  alias {
    name                   = module.alb_main_ext.dns_name
    zone_id                = module.alb_main_ext.zone_id
    evaluate_target_health = true
  }
}