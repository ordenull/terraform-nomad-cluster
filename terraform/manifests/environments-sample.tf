variable "aws" {
  description = "AWS provider configuration"
  default = {
    # These are looked up for each workspace
    "prod" = {
      account = "000000000000"
      region  = "us-east-2"
      role    = "terraform-prod"
    }
    "dev" = {
      account = "000000000000"
      region  = "us-east-2"
      role    = "terraform-dev"
    }
  }
}

# You must have a top level domain for the "subdomain" that you specify here in the same AWS account
# Delegation records will be automatically created in the TLD. The domain is used for the SSL certificate.
variable "vpc" {
  description = "VPC configuration"
  default = {
    # These are looked up for each workspace
    "prod" = {
      vpc_cidr    = "10.3.0.0/20"
      subnet_mask = "24"
      domain      = "prod-aws.xeraweb.net"
    }
    "dev" = {
      vpc_cidr    = "10.2.128.0/20"
      subnet_mask = "24"
      domain      = "dev-aws.xeraweb.net"
    }
  }
}

variable "tags" {
  description = "Common tags for resources in a workspace"
  default = {
    # These are looked up for each workspace
    "prod" = {
      owner      = "stan@borbat.com"
      maintainer = "terraform"
      env        = "prod"
    }
    "dev" = {
      owner      = "stan@borbat.com"
      maintainer = "terraform"
      env        = "dev"
    }
  }
}

# The following are shared for all workspaces

variable "github_username" {
  description = "GitHub username from which to pull the public SSH keys. First one will be used."
  default = "ordenull"
}

variable "trusted_cidr" {
  description = "Trusted WAN subnets used to secure SSH and Nomad Dashboard. Do not add 0.0.0.0/0"
  default = [
    "xx.xx.xx.xx/32" # Get your IP with http://checkip.dyndns.org
  ]
}