variable "prefix" {
  description = "Envionment name (prefix)"
}

variable "name" {
  description = "The name of the Target Group"
}

variable "tags" {
  description = "Tags to apply to the created resources"
  type        = map
}

variable "vpc_subnets" {
  description = "Subnets where the Application Load Balancer was deployed"
  type        = list
}

variable "listener_arn" {
  description = "The ARN of the Application Load Balancer Listener to attach this to"
}

variable "listener_priority" {
  description = "The priority (order) of this listener rule in respoect to others on the same linstener"
  default     = "100"
}

variable "listener_rule_hosts" {
  description = "The value of the HTTP Host header to match"
  default     = "*"
}

variable "listener_rule_paths" {
  description = "The value of the HTTP path to match"
  default     = "*"
}

variable "listener_rule_cidr" {
  description = "The list of subnets in CIDR notation to match the source IP address"
  default     = ["0.0.0.0/0"]
}

variable "instance_port" {
  description = "The port of the EC2 instance to target"
}

variable "instance_deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused"
  default     = 30
}

variable "health_enabled" {
  description = "Enables target health checks"
  default     = "true"
}

variable "health_interval" {
  description = "The time between health checks in seconds"
  default      = 10
}

variable "health_path" {
  description = "The HTTP path for the health check to request"
  default     = "/healthz"
}

variable "health_timeout" {
  description = "The time to wait for the health endpoint to respond"
  default     = 5
}

variable "health_healthy_threshold" {
  description = "The number of consecutive health checks that have to pass to be deemed healthy"
  default     = 2
}

variable "health_unhealthy_threshold" {
  description = "The number of consecutive health checks that have to pass to be deemed unhealthy"
  default     = 2
}

variable "health_matcher" {
  description = "The list of HTTP response codes to accept as success"
  default     = [200]
}

variable "stickiness_enabled" {
  description = "Enable cookie session stickiness"
  default = false
}