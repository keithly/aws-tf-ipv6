resource "aws_vpc" "tf_vpc" {
  cidr_block                       = "10.0.0.0/26"
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_subnet" "tf_subnet_1" {
  cidr_block              = "10.0.0.0/28"
  ipv6_cidr_block         = "2600:1f16:c47:be00::/64"
  vpc_id                  = aws_vpc.tf_vpc.id
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "tf_subnet_1"
  }
}

resource "aws_subnet" "tf_subnet_2" {
  cidr_block              = "10.0.0.32/28"
  ipv6_cidr_block         = "2600:1f16:c47:be01::/64"
  vpc_id                  = aws_vpc.tf_vpc.id
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "tf_subnet_2"
  }
}

resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_igw"
  }
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "tf_rt"
  }
}

resource "aws_route_table_association" "tf_rta_1" {
  route_table_id = aws_route_table.tf_rt.id
  subnet_id      = aws_subnet.tf_subnet_1.id
}

resource "aws_route_table_association" "tf_rta_2" {
  route_table_id = aws_route_table.tf_rt.id
  subnet_id      = aws_subnet.tf_subnet_2.id
}

resource "aws_security_group" "tf_sg" {
  name        = "sg_public"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_network_acl" "tf_nacl" {
  vpc_id = aws_vpc.tf_vpc.id
  subnet_ids = [
    aws_subnet.tf_subnet_1.id,
    aws_subnet.tf_subnet_2.id]

  tags = {
    Name = "tf_nacl"
  }
}

resource "aws_network_acl_rule" "acl_rule_ingress" {
  count = length(var.network_acl_ingress)

  network_acl_id = aws_network_acl.tf_nacl.id

  egress          = false
  rule_number     = var.network_acl_ingress[count.index]["rule_no"]
  rule_action     = var.network_acl_ingress[count.index]["action"]
  from_port       = lookup(var.network_acl_ingress[count.index], "from_port", null)
  to_port         = lookup(var.network_acl_ingress[count.index], "to_port", null)
  icmp_code       = lookup(var.network_acl_ingress[count.index], "icmp_code", null)
  icmp_type       = lookup(var.network_acl_ingress[count.index], "icmp_type", null)
  protocol        = var.network_acl_ingress[count.index]["protocol"]
  cidr_block      = lookup(var.network_acl_ingress[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.network_acl_ingress[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "acl_rule_egress" {
  count = length(var.network_acl_egress)

  network_acl_id = aws_network_acl.tf_nacl.id

  egress          = true
  rule_number     = var.network_acl_egress[count.index]["rule_no"]
  rule_action     = var.network_acl_egress[count.index]["action"]
  from_port       = lookup(var.network_acl_egress[count.index], "from_port", null)
  to_port         = lookup(var.network_acl_egress[count.index], "to_port", null)
  icmp_code       = lookup(var.network_acl_egress[count.index], "icmp_code", null)
  icmp_type       = lookup(var.network_acl_egress[count.index], "icmp_type", null)
  protocol        = var.network_acl_egress[count.index]["protocol"]
  cidr_block      = lookup(var.network_acl_egress[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup(var.network_acl_egress[count.index], "ipv6_cidr_block", null)
}
