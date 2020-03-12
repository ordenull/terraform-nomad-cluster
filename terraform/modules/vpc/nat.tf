resource "aws_eip" "nat" {
  count = var.enable_nat_gateways ? length(var.availability_zones) : 0
  vpc   = true
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-nat-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateways ? length(var.availability_zones) : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge(
    var.tags,
    {
      "Name" = "${var.prefix}-nat-${var.availability_zones[count.index]}"
    }
  )
}

resource "aws_route" "private_default_ipv4" {
  count                   = var.enable_nat_gateways ? length(var.availability_zones) : 0
  route_table_id          = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = element(aws_nat_gateway.main.*.id, count.index)
  depends_on              = [aws_route_table.private]
}