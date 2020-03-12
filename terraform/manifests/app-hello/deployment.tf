locals {
  ecr_host         = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  nomad_datacenter = "${terraform.workspace}-nomad"
  frontend_port    = 8080
  codename         = "hello"
  health_path      = "/health"
}

## Data
#################################################################
data "aws_autoscaling_group" "clients_frontend" {
  name = local.nomad_clients_frontend_asg
}

## Nomad Task
#################################################################
data "template_file" "job_hcl_frontend" {
  template = "${file("${path.module}/nomad-job-hcl.tpl")}"

  vars = {
    target_datacenter = "${terraform.workspace}-nomad"
    target_nodeclass  = "frontend"
    region            = data.aws_region.current.name
    ecr_host          = local.ecr_host
    replicas          = data.aws_autoscaling_group.clients_frontend.desired_capacity
    version           = "latest"
    frontend_port     = local.frontend_port
    health_path       = local.health_path
  }
}

resource "nomad_job" "frontend" {
  jobspec = data.template_file.job_hcl_frontend.rendered
}

## Target group to connect to the port of the running containers
#################################################################
module "nomad_frontend_target_group" {
  source              = "../../modules/alb-instance-target"
  prefix              = terraform.workspace
  name                = "nomad-${local.codename}"
  tags                = var.tags[terraform.workspace]
  vpc_subnets         = local.vpc_subnets
  listener_arn        = local.alb_listener_arn
  listener_priority   = 200
  listener_rule_cidr  = ["0.0.0.0/0"]
  listener_rule_hosts = ["${local.codename}.${var.vpc[terraform.workspace]["domain"]}"]
  listener_rule_paths = ["*"]
  instance_port       = local.frontend_port
  health_path         = local.health_path
}

# Allow the ALB to connect to the HTTP interface
resource "aws_security_group_rule" "nomad_clients_hello_alb" {
  protocol                 = "tcp"
  security_group_id        = local.nomad_clients_frontend_sg
  source_security_group_id = local.alb_security_group
  from_port                = local.frontend_port
  to_port                  = local.frontend_port
  type                     = "ingress"
  description              = "TF: Nomad ALB"
}

# Automatically attach server instances to the dashboard target group
resource "aws_autoscaling_attachment" "ext" {
  autoscaling_group_name = local.nomad_clients_frontend_asg
  alb_target_group_arn   = module.nomad_frontend_target_group.target_group_arn
}

# Create a nice DNS name to access the dashboard
resource "aws_route53_record" "nomad_servers" {
  zone_id = local.vpc_public_zone_id
  name    = "${local.codename}.${var.vpc[terraform.workspace]["domain"]}"
  type    = "A"
  alias {
    name                   = local.alb_dns_name
    zone_id                = local.alb_zone_id
    evaluate_target_health = true
  }
}