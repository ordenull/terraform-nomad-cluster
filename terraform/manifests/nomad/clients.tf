## Nomad Clients (Workers)
#################################################################
module "nomad_clients_frontend" {
  source                = "../../modules/nomad-clients"
  prefix                = terraform.workspace
  cluster               = "nomad"
  server                = "server"
  name                  = "frontend"
  tags                  = var.tags[terraform.workspace]

  vpc_subnets           = local.vpc_public_subnets
  vpc_public_ip         = true
  vpc_addon_sgs         = [local.vpc_public_main_sg]

  asg_capacity_min      = 0
  asg_capacity_max      = 4
  asg_capacity_default  = 2
  asg_health_check_type = "EC2"

  instance_key          = aws_key_pair.admin.key_name
  instance_type         = "t2.small"
  instance_ami          = data.aws_ami.base_ami.id
  
  volume_root_size      = 10

  # Harden the install
  enable_consul_dns     = true
  protect_consul_api    = true
  protect_host_ssh      = true
  protect_aws_metadata  = true
  protect_services      = true
}