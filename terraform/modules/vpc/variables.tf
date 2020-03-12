variable "prefix" {
  description = "Envionment name (prefix)"
}

variable "domain" {
  description = "Fully qualified domain name suffix"
}

variable "vpc_cidr" {
  description = "Subnet in CIDR notation assigned to this environment"
  default     = "10.0.0.0/20"
}

variable "subnet_mask" {
  description = "Desired mask for the VPC subnets"
  default     = "24"
}

variable "enable_private_link_s3" {
  description = "Enable a private link endpoint for S3"
  default     = true
}

variable "enable_private_link_docker" {
  description = "Enable a private link endpoint for ECR ($16.4 / month with 2 AZs)"
  default     = false
}

variable "enable_nat_gateways" {
  description = "Enable NAT gateways on the private subnets ($64.8 / month with 2 AZs)"
  default     = false
}

variable "enable_private_ipv6_egress" {
  description = "Enable Egress Only Internet Gateways on the private subnets"
  default     = false
}

variable "trusted_cidr" {
  description = "Subnets that are trusted to connect via ssh to public instances"
  default     = []
}

variable "availability_zones" {
  description = "Availability zones to use"
  default     = ["a","b"]
}

variable "tags" {
  description = "Tags to apply to the created resources"
  type        = map
}