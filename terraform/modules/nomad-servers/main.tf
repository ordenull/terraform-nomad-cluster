## Data Sources
#################################################################
data "aws_subnet" "selected" {
  id = tolist(var.vpc_subnets)[0]
}

## Security Groups
#################################################################
resource "aws_security_group" "server" {
  name        = "${var.cluster}-${var.name}"
  description = "${var.prefix}-${var.cluster}: Noad server pool"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags        = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-${var.cluster}",
    }
  )
}

## Nomad RPC
resource "aws_security_group_rule" "server_nomad_self_rpc" {
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 4647
  to_port                  = 4647
  type                     = "ingress"
  description              = "TF: Nomad Server RCP"
}

resource "aws_security_group_rule" "server_nomad_client_rpc" {
  count                    = length(var.allowed_client_sgs)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = var.allowed_client_sgs[count.index]
  from_port                = 4647
  to_port                  = 4647
  type                     = "ingress"
  description              = "TF: Nomad Client RCP"
}

## Consul RPC
resource "aws_security_group_rule" "server_consul_self_rpc" {
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 8300
  to_port                  = 8300
  type                     = "ingress"
  description              = "TF: Consul Server RCP"
}

resource "aws_security_group_rule" "server_consul_client_rpc" {
  count                    = length(var.allowed_client_sgs)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = var.allowed_client_sgs[count.index]
  from_port                = 8300
  to_port                  = 8300
  type                     = "ingress"
  description              = "TF: Consul Client RCP"
}

## Nomad Gossip
resource "aws_security_group_rule" "server_nomad_self_gossip_tcp" {
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 4648
  to_port                  = 4648
  type                     = "ingress"
  description              = "TF: Nomad Server Gossip"
}

resource "aws_security_group_rule" "server_nomad_self_gossip_udp" {
  protocol                 = "udp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 4648
  to_port                  = 4648
  type                     = "ingress"
  description              = "TF: Nomad Server Gossip"
}

## Consul Gossip
resource "aws_security_group_rule" "server_consul_self_gossip_tcp" {
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 8301
  to_port                  = 8301
  type                     = "ingress"
  description              = "TF: Consul Server Gossip"
}

resource "aws_security_group_rule" "server_consul_self_gossip_udp" {
  protocol                 = "udp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = aws_security_group.server.id
  from_port                = 8301
  to_port                  = 8301
  type                     = "ingress"
  description              = "TF: Consul Server Gossip"
}

resource "aws_security_group_rule" "server_consul_client_gossip" {
  count                    = length(var.allowed_client_sgs)
  protocol                 = "tcp"
  security_group_id        = aws_security_group.server.id
  source_security_group_id = var.allowed_client_sgs[count.index]
  from_port                = 8301
  to_port                  = 8301
  type                     = "ingress"
  description              = "TF: Consul Client Gossip"
}

## IAM Role
#################################################################
resource "aws_iam_role" "server" {
  name                  = "${var.prefix}-${var.cluster}-${var.name}"
  assume_role_policy    = data.aws_iam_policy_document.server_assume_role_policy.json
  force_detach_policies = true
  tags                  = var.tags
}

data "aws_iam_policy_document" "server_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "server" {
  name = "${var.prefix}-${var.cluster}-${var.name}"
  role = aws_iam_role.server.name
}

resource "aws_iam_role_policy_attachment" "server_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.server.name
}

resource "aws_iam_role_policy_attachment" "server_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.server.name
}

data "aws_iam_policy_document" "server_autodiscover" {
  policy_id = "ec2-describe"

  statement {
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_role_policy" "server_autodiscover" {
  role   = aws_iam_role.server.name
  name   = data.aws_iam_policy_document.server_autodiscover.policy_id
  policy = data.aws_iam_policy_document.server_autodiscover.json
}

## Auto Scaling Group
#################################################################
resource "aws_autoscaling_group" "server" {
  name                  = "${var.prefix}-${var.cluster}-${var.name}"
  min_size              = var.asg_capacity_min
  max_size              = var.asg_capacity_max
  desired_capacity      = var.asg_capacity_default
  health_check_type     = var.asg_health_check_type
  vpc_zone_identifier   = var.vpc_subnets
  termination_policies  = ["OldestInstance"]
  enabled_metrics       = [
    "GroupInServiceInstances",
  ]

  launch_template {
    id      = aws_launch_template.server.id
    version = "$Latest"
  }

  tags = concat(
    # List of tags defined below this resource
    local.asg_tags,
    list(
      {
        key                 = "Name",
        value               = "${var.prefix}-${var.cluster}-${var.name}",
        propagate_at_launch = true,
      },
      {
        key                 = "nomad:role",
        value               = "server",
        propagate_at_launch = true,
      },
      {
        key                 = "nomad:cluster",
        value               = var.cluster,
        propagate_at_launch = true,
      },
      {
        key                 = "nomad:discover",
        value               = "${var.prefix}-${var.cluster}"
        propagate_at_launch = true,
      }
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [desired_capacity]
  }
}

# Convert the tags map to a list of maps for the ASG above
resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(var.tags))

  triggers = {
    key                 = element(keys(var.tags), count.index)
    value               = element(values(var.tags), count.index)
    propagate_at_launch = "true"
  }
}

locals {
  asg_tags = null_resource.tags_as_list_of_maps.*.triggers
}

data "template_file" "server_userdata_header" {
  template = "${file("${path.module}/userdata/00-header.tpl")}"

  vars = {
    datacenter           = "${var.prefix}-${var.cluster}"
    discover_tag_value   = "${var.prefix}-${var.cluster}"
    nomad_version        = "${var.version_nomad}"
    consul_version       = "${var.version_consul}"

    protect_aws_metadata = var.protect_aws_metadata ? 1 : 0

    expect_servers       = max(var.asg_capacity_default, 1) # This must be 1 or greater
    nomad_port_http      = var.nomad_port_http
    consul_port_http     = var.consul_port_http
    node_gc_threshold    = var.node_gc_threshold
    job_gc_threshold     = var.job_gc_threshold
  }
}

locals {
  # The userdata is split into multiple files because bash varialbe
  # interpolation ${VAR} conflicts with terraform template's own.
  # This allows us to use the template syntax to pass our variables,
  # and to keep native bash syntax for the initialization scripts.
  userdata = join("\n",
    [
      data.template_file.server_userdata_header.rendered,
      file("${path.module}/userdata/01-install-deps.sh"),
      file("${path.module}/userdata/02-install-hashi.sh"),
      file("${path.module}/userdata/05-config-harden.sh"),
      file("${path.module}/userdata/06-config-hashi.sh"),
      file("${path.module}/userdata/10-config-systemd.sh"),
    ]
  )
}

resource "aws_launch_template" "server" {
  name                                 = "${var.prefix}-${var.cluster}-${var.name}"
  key_name                             = var.instance_key
  instance_type                        = var.instance_type
  image_id                             = var.instance_ami
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = lookup(local.ebs_optimized, var.instance_type, false)
  user_data                            = base64encode(local.userdata)
  tags                                 = var.tags

  block_device_mappings {
    device_name = "/dev/xvda"
    no_device   = true
    ebs {
      delete_on_termination = true
      volume_size           = var.volume_root_size
      volume_type           = var.volume_root_type
      iops                  = var.volume_root_iops
      encrypted             = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.server.name
  }

  monitoring {
    enabled = var.instance_monitoring
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = var.vpc_public_ip
    security_groups             = concat([aws_security_group.server.id], var.vpc_addon_sgs)
  }

  lifecycle {
    create_before_destroy = true
  }
}