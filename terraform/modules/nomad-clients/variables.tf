variable "prefix" {
  description = "Envionment name (prefix)"
}

variable "cluster" {
  description = "The name of the cluster. This will be used for naming and discovery"
}

variable "server" {
  description = "The name of the server. This will be used for naming and discovery"
}

variable "name" {
  description = "The name of the worker group, that will be used for naming resources"
}

variable "tags" {
  description = "Tags to apply to the created resources"
  type        = map
}

variable "vpc_subnets" {
  description = "Subnets where to deploy the cluster"
  type        = list
}

variable "vpc_public_ip" {
  description = "Attach a public IP to each instance"
  type        = bool
}

variable "vpc_addon_sgs" {
  description = "Additional security groups to attach to each instance"
  type        = list
}


variable "asg_capacity_min" {
  description = "Initial number of instances"
  default     = 1
}

variable "asg_capacity_max" {
  description = "Initial number of instances"
  default     = 3
}

variable "asg_capacity_default" {
  description = "Initial number of instances"
  default     = 1
}

variable "asg_health_check_type" {
  description = "The type of health check to use for the instances EC2|ELB"
  default     = "EC2"
}


variable "instance_key" {
  description = "The name of the SSH key to deploy to the instances"
}

variable "instance_type" {
  description = "The type of EC2 instances to use"
}

variable "instance_ami" {
  description = "The base AMI for the instances"
}

variable "instance_monitoring" {
  description = "Enable detailed monitoring on each instance"
  default     = false
}

variable "volume_root_size" {
  description = "The size of the instance's root volume"
  default     = 20
}

variable "volume_root_type" {
  description = "The type of the instance's root volume"
  default     = "standard"
}

variable "volume_root_iops" {
  description = "The number of IOPS to privion for the instance's root volume"
  default     = 0
}

variable "enable_consul_dns" {
  description = "Forward docker container DNS look-ups to consul DNS"
  default     = false
}

variable "protect_consul_api" {
  description = "Harden the install restricting access to consul API from docker containers"
  default     = false
}

variable "protect_host_ssh" {
  description = "Harden the install restricting access to host SSH from docker containers"
  default     = false
}

variable "protect_aws_metadata" {
  description = "Harden the install restricting access to AWS metadata service"
  default     = false
}

variable "protect_services" {
  description = "Harden the install restricting access to system services from docker containers"
  default     = false
}

variable "version_nomad" {
  description = "Version of HashiCorp Nomad to deploy"
  default     = "0.10.4"
}

variable "version_consul" {
  description = "Version of HashiCorp Consul to deploy"
  default     = "1.7.1"
}