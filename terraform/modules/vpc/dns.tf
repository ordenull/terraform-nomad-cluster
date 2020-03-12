## Route53 Zones
#################################################################
resource "aws_route53_zone" "public" {
  name    = var.domain
  comment = var.prefix

  tags = merge(
    var.tags,
    {
      "Prefix"   = var.prefix
      "dns:tier" = "public"
    }
  )
}

resource "aws_route53_zone" "private" {
  name    = var.domain
  comment = var.prefix

  vpc {
    vpc_id  = aws_vpc.main.id
  }

  tags = merge(
    var.tags,
    {
      "Prefix"   = var.prefix
      "dns:tier" = "private"
    }
  )
}

resource "aws_route53_zone" "reverse" {
  name    = "10.in-addr.arpa."
  comment = var.prefix

  vpc {
    vpc_id  = aws_vpc.main.id
  }

  tags = merge(
    var.tags,
    {
      "Prefix"   = var.prefix
      "dns:tier" = "reverse"
    }
  )
}
