variable "prefix" {
  description = "Envionment name (prefix)"
}

variable "name" {
  description = "The name of the Application Load Balancer"
}

variable "description" {
  description = "The description of the Application Load Balancer"
}

variable "tags" {
  description = "Tags to apply to the created resources"
  type        = map
}

variable "vpc_subnets" {
  description = "Subnets where to deploy the Application Load Balancer"
  type        = list
}

variable "vpc_addon_sgs" {
  description = "Additional security groups to attach to the Application Load Balancer"
  type        = list
}

variable "alb_allowed_cidr4" {
  description = "IPv4 subnets that are trusted to connect to this load balancer"
  default     = [
    "0.0.0.0/0"
  ]
}

variable "alb_allowed_cidr6" {
  description = "IPv6 subnets that are trusted to connect to this load balancer"
  default     = [
    "::/0"
  ]
}

variable "internal" {
  description = "Create an internal Application Load Balancer"
  default     = false
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  default     = 30
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  default     = true
}

variable "ssl_policy" {
  description = "SSL policy to use on the HTTPS listener"
  default     = "ELBSecurityPolicy-FS-2018-06"
}

variable "ssl_cert_arn" {
  description = "SSL certificate's ARN for the HTTPS listener"
}


