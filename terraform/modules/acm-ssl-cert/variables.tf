variable "prefix" {
  description = "Envionment name (prefix)"
}

variable "name" {
  description = "The name of the Application Load Balancer"
}

variable "domain" {
  description = "The Common Name on the certificate"
}

variable "validation_route53_zoneid" {
  description = "The Route53 zone ID that is delegated to the domain"
}

variable "tags" {
  description = "Tags to apply to the created resources"
  type        = map
}