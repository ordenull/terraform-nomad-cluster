## Sourced from remote state from VPC
#################################################################
data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate.d/${terraform.workspace}/terraform.tfstate"
  }
}

locals {
  vpc_public_subnets   = data.terraform_remote_state.vpc.outputs.vpc_public_subnets
  vpc_private_subnets  = data.terraform_remote_state.vpc.outputs.vpc_private_subnets
  vpc_public_zone_id   = data.terraform_remote_state.vpc.outputs.vpc_public_zone_id
  vpc_public_main_sg   = data.terraform_remote_state.vpc.outputs.vpc_public_main_sg
  vpc_private_main_sg  = data.terraform_remote_state.vpc.outputs.vpc_private_main_sg
  vpc_acm_wildcard_arn = data.terraform_remote_state.vpc.outputs.vpc_acm_wildcard_arn
}