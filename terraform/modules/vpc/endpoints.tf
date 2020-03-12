## VPC S3 Endpoint
#################################################################
resource "aws_vpc_endpoint" "s3" {
  count           = var.enable_private_link_s3 ? 1 : 0
  vpc_id          = aws_vpc.main.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = concat([aws_route_table.public.id], aws_route_table.private.*.id)

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-s3"
      "vpc:tier" = "private"
    }
  )
}


## VPC ECR Endpoint
#################################################################
resource "aws_security_group" "ecr" {
  count       = var.enable_private_link_docker ? 1 : 0
  name        = "main-ecr"
  description = "${var.prefix} - All ECR Endpoint Interfaces"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-main-ecr"
    }
  )
}

resource "aws_security_group_rule" "ecr_egress_ipv4" {
  count                    = var.enable_private_link_docker ? 1 : 0
  security_group_id        = aws_security_group.ecr[0].id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  cidr_blocks              = ["0.0.0.0/0"]
  description              = "TF: Unrestricted IPv4 egress"
}

resource "aws_security_group_rule" "ecr_egress_ipv6" {
  count                    = var.enable_private_link_docker ? 1 : 0
  security_group_id        = aws_security_group.ecr[0].id
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  ipv6_cidr_blocks         = ["::/0"]
  description              = "TF: Unrestricted IPv6 egress"
}

resource "aws_security_group_rule" "ecr_ingress_public" {
  count                    = var.enable_private_link_docker ? 1 : 0
  security_group_id        = aws_security_group.ecr[0].id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main_public.id
  description              = "TF: Ingress from public subnets"
}

resource "aws_security_group_rule" "ecr_ingress_private" {
  count                    = var.enable_private_link_docker ? 1 : 0
  security_group_id        = aws_security_group.ecr[0].id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.main_private.id
  description              = "TF: Ingress from private subnets"
}

# Only needed for ECR
resource "aws_vpc_endpoint" "ecr_api" {
  count               = var.enable_private_link_docker ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    "${aws_security_group.ecr[0].id}",
  ]

  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-ecr-api"
      "vpc:tier" = "private"
    }
  )
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count               = var.enable_private_link_docker ? 1 : 0
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    "${aws_security_group.ecr[0].id}",
  ]

  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-ecr-dkr"
      "vpc:tier" = "private"
    }
  )
}