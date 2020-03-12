## Data
#################################################################
data "aws_region" "current" {}

## VPCs
#################################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = merge(
    var.tags,
    {
      "Name" = var.prefix
    }
  )
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name          = var.domain
  domain_name_servers  = ["AmazonProvidedDNS"]

  tags = merge(
    var.tags,
    {
      "Name" = var.prefix
    }
  )
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-default"
    }
  )
}

## Gateways
#################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = var.prefix
    }
  )
}

resource "aws_egress_only_internet_gateway" "main" {
  count  = var.enable_private_ipv6_egress ? 1 : 0
  vpc_id = aws_vpc.main.id
}

## Routing Tables
#################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-public"
    }
  )
}

resource "aws_route" "public_default_ipv4" {
  route_table_id          = aws_route_table.public.id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.main.id
  depends_on              = [aws_route_table.public]
}

resource "aws_route" "public_default_ipv6" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.main.id
  depends_on                  = [aws_route_table.public]
}

resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-private-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_route" "private_default_ipv6" {
  count                       = var.enable_private_ipv6_egress ? length(var.availability_zones) : 0
  route_table_id              = element(aws_route_table.private.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.main[0].id
  depends_on                  = [aws_route_table.private]
}

## Subnets
#################################################################
locals {
  vpc_bits       = element(split("/", var.vpc_cidr), 1)
  total_subnets  = pow(2, var.subnet_mask - element(split("/", var.vpc_cidr), 1))
  public_offset  = 0
  private_offset = 0 + length(var.availability_zones)
}

# This is used to generate a list of available subnets
resource "null_resource" "subnets" {
  count = local.total_subnets
  triggers = {
    cidr = cidrsubnet(var.vpc_cidr, var.subnet_mask - local.vpc_bits, count.index)
  }
}

resource "aws_subnet" "public" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = element(formatlist("%s", null_resource.subnets.*.triggers.cidr), local.public_offset + count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, local.public_offset + count.index)
  availability_zone               = "${data.aws_region.current.name}${var.availability_zones[count.index]}"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-public-${var.availability_zones[count.index]}"
      "vpc:zone" = var.availability_zones[count.index]
      "vpc:tier" = "public"
    }
  )
}
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count                           = length(var.availability_zones)
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = element(formatlist("%s", null_resource.subnets.*.triggers.cidr), local.private_offset + count.index)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, local.private_offset + count.index)
  availability_zone               = "${data.aws_region.current.name}${var.availability_zones[count.index]}"
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = true

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-private-${var.availability_zones[count.index]}"
      "vpc:zone" = var.availability_zones[count.index]
      "vpc:tier" = "private"
    }
  )
}
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}

## Default Security Group
#################################################################
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-default"
    }
  )
}

## Main Public Security Group
#################################################################
resource "aws_security_group" "main_public" {
  name        = "main-public"
  description = "${var.prefix} - All Public EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-main-public"
    }
  )
}

resource "aws_security_group_rule" "main_public_egress_ipv4" {
  security_group_id        = aws_security_group.main_public.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "TF: Unrestricted IPv4 egress"
}

resource "aws_security_group_rule" "main_public_egress_ipv6" {
  security_group_id        = aws_security_group.main_public.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  ipv6_cidr_blocks         = ["::/0"]
  description              = "TF: Unrestricted IPv6 egress"
}

resource "aws_security_group_rule" "main_public_ssh_trusted" {
  security_group_id        = aws_security_group.main_public.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = var.trusted_cidr
  description              = "TF: Trusted SSH"
}

resource "aws_security_group_rule" "main_public_ssh_bastion" {
  security_group_id        = aws_security_group.main_public.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  description              = "TF: Bastion SSH"
}

## Main Private Security Group
#################################################################
resource "aws_security_group" "main_private" {
  name        = "main-private"
  description = "${var.prefix} - All Private EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-main-private"
    }
  )
}

resource "aws_security_group_rule" "main_private_egress_ipv4" {
  security_group_id        = aws_security_group.main_private.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "TF: Unrestricted IPv4 egress"
}

resource "aws_security_group_rule" "main_private_egress_ipv6" {
  security_group_id        = aws_security_group.main_private.id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  ipv6_cidr_blocks         = ["::/0"]
  description              = "TF: Unrestricted IPv6 egress"
}

resource "aws_security_group_rule" "main_private_ssh_bastion" {
  security_group_id        = aws_security_group.main_private.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  description              = "TF: Bastion SSH"
}

## Bastion Security Group
#################################################################
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "${var.prefix} - Instances allowed to access everything via SSH"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-bastion"
    }
  )
}