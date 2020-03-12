## Data Sources
#################################################################
data "aws_subnet" "selected" {
  id = tolist(var.vpc_subnets)[0]
}

## Security Groups
##################################################################
resource "aws_security_group" "main" {
  name        = "${var.prefix}-${var.name}"
  description = "${var.prefix}-${var.name}: ${var.description}"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-${var.name}",
    }
  )
}

resource "aws_security_group_rule" "main_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "main_ingress_http" {
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = var.alb_allowed_cidr4
  ipv6_cidr_blocks  = var.alb_allowed_cidr6
  description       = "TF: Default HTTP"
}

resource "aws_security_group_rule" "main_ingress_https" {
  security_group_id = aws_security_group.main.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = var.alb_allowed_cidr4
  ipv6_cidr_blocks  = var.alb_allowed_cidr6
  description       = "TF: Default HTTPS"
}

## Application Load Balancer
##################################################################
resource "aws_alb" "main" {
  name            = "${var.prefix}-${var.name}"
  subnets         = var.vpc_subnets
  security_groups = concat([aws_security_group.main.id], var.vpc_addon_sgs)

  idle_timeout    = var.idle_timeout
  enable_http2    = var.enable_http2
  internal        = var.internal
  ip_address_type = "dualstack"

  tags        = merge(
    var.tags,
    {
      "alb:internal" = var.internal,
    }
  )
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.ssl_cert_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Page not found"
      status_code  = "404"
    }
  }
}