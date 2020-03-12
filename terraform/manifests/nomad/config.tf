## Base AMI
#################################################################
data "aws_ami" "base_ami" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200207.1-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

## SSH Keypair
#################################################################
data "http" "ssh_public_keys" {
  url = "https://github.com/${var.github_username}.keys"
}

resource "aws_key_pair" "admin" {
  key_name   = "github-${var.github_username}"
  public_key = split("\n", data.http.ssh_public_keys.body)[0]
}