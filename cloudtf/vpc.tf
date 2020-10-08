
resource "aws_vpc" "default" {
  cidr_block = "172.16.0.0/16"
  assign_generated_ipv6_cidr_block = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "outgoing_ipv4" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.default.id
  route_table_id = aws_route_table.default.id
}

resource "aws_route" "outgoing_ipv6" {
  destination_ipv6_cidr_block = "::/0"
  gateway_id = aws_internet_gateway.default.id
  route_table_id = aws_route_table.default.id
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.default.id
  cidr_block = "172.16.1.0/24"
  map_public_ip_on_launch = false
  ipv6_cidr_block = cidrsubnet(aws_vpc.default.ipv6_cidr_block, 8, 254)
  assign_ipv6_address_on_creation = true
}

resource "aws_route_table_association" "subnet_a" {
  route_table_id = aws_route_table.default.id

  subnet_id = aws_subnet.subnet_a.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group" "default" {
  vpc_id      = aws_vpc.default.id
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.default.id

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

