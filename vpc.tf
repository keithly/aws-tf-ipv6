resource "aws_vpc" "tf_vpc" {
  cidr_block                       = "10.0.0.0/26"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "tf_vpc"
  }
}

resource "aws_subnet" "tf_subnet_public_1" {
  cidr_block                      = cidrsubnet(aws_vpc.tf_vpc.cidr_block, 2, 0)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.tf_vpc.ipv6_cidr_block, 8, 0)
  vpc_id                          = aws_vpc.tf_vpc.id
  availability_zone               = "us-east-2a"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "tf_subnet_public_1"
  }
}

resource "aws_subnet" "tf_subnet_public_2" {
  cidr_block                      = cidrsubnet(aws_vpc.tf_vpc.cidr_block, 2, 1)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.tf_vpc.ipv6_cidr_block, 8, 1)
  vpc_id                          = aws_vpc.tf_vpc.id
  availability_zone               = "us-east-2b"
  map_public_ip_on_launch         = true
  assign_ipv6_address_on_creation = true

  tags = {
    Name = "tf_subnet_public_2"
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

resource "aws_route_table_association" "tf_rta_public_1" {
  route_table_id = aws_route_table.tf_rt.id
  subnet_id      = aws_subnet.tf_subnet_public_1.id
}

resource "aws_route_table_association" "tf_rta_public_2" {
  route_table_id = aws_route_table.tf_rt.id
  subnet_id      = aws_subnet.tf_subnet_public_2.id
}

resource "aws_security_group" "tf_sg_public_http" {
  name        = "sg_public_http"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf_sg_public"
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
