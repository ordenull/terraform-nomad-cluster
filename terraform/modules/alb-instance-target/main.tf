## Data Sources
#################################################################
data "aws_subnet" "selected" {
  id = tolist(var.vpc_subnets)[0]
}

resource "aws_alb_target_group" "main" {
  name                 = "${var.prefix}-${var.name}"
  port                 = var.instance_port
  protocol             = "HTTP"
  vpc_id               = data.aws_subnet.selected.vpc_id
  deregistration_delay = var.instance_deregistration_delay

  health_check {
    enabled             = var.health_enabled
    interval            = var.health_interval
    path                = var.health_path
    protocol            = "HTTP"
    timeout             = var.health_timeout
    healthy_threshold   = var.health_healthy_threshold
    unhealthy_threshold = var.health_unhealthy_threshold
    matcher             = join(",", var.health_matcher)
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = var.stickiness_enabled
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

## Nomad Clients (Workers) ALB Target Groups
#################################################################
resource "aws_lb_listener_rule" "main" {
  listener_arn = var.listener_arn
  priority     = var.listener_priority

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    source_ip {
      values = var.listener_rule_cidr
    }
  }

  condition {
    host_header {
      values = var.listener_rule_hosts
    }
  }

  condition {
    path_pattern {
      values = var.listener_rule_paths
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}