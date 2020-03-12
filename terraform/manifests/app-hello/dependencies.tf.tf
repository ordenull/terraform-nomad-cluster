## Sourced from remote state from vpc
#################################################################
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

locals {
  vpc_subnets        = data.terraform_remote_state.vpc.outputs.vpc_public_subnets
  vpc_public_zone_id = data.terraform_remote_state.vpc.outputs.vpc_public_zone_id
}

## Sourced from remote state from nomad cluster
#################################################################
data "terraform_remote_state" "nomad" {
  backend = "local"

  config = {
    path = "../nomad/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

locals {
  alb_listener_arn            = data.terraform_remote_state.nomad.outputs.alb_main_listener_arn
  alb_security_group          = data.terraform_remote_state.nomad.outputs.alb_main_security_group
  alb_dns_name                = data.terraform_remote_state.nomad.outputs.alb_main_dns_name
  alb_zone_id                 = data.terraform_remote_state.nomad.outputs.alb_main_zone_id
  nomad_clients_frontend_sg   = data.terraform_remote_state.nomad.outputs.nomad_clients_frontend_sg
  nomad_clients_frontend_asg  = data.terraform_remote_state.nomad.outputs.nomad_clients_frontend_asg
}