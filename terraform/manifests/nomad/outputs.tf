output "nomad_clients_frontend_sg" {
  value = module.nomad_clients_frontend.client_security_group_id
}

output "nomad_clients_frontend_asg" {
  value = module.nomad_clients_frontend.client_asg_name  
}


output "alb_main_listener_arn" {
  value = module.alb_main_ext.https_listener_arn
}

output "alb_main_security_group" {
  value = module.alb_main_ext.security_group_id
}

output "alb_main_dns_name" {
  value = module.alb_main_ext.dns_name
}

output "alb_main_zone_id" {
  value = module.alb_main_ext.zone_id
}