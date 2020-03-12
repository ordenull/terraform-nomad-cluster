provider "aws" {
  region = var.aws[terraform.workspace]["region"]
  assume_role {
    role_arn = "arn:aws:iam::${var.aws[terraform.workspace]["account"]}:role/${var.aws[terraform.workspace]["role"]}"
  }
}

terraform {
  required_version = ">=0.12"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}