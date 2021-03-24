data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 50
}

resource "random_shuffle" "az" {
  input = data.aws_availability_zones.available.names
  result_count = var.max_subnet
}

resource "aws_vpc" "cloud_network" {
  cidr_block = var.network_cidr_in
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloud-network-${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "cloud_network_public" {
  count = length(var.public_cidrs)
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = random_shuffle.az.result[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "cloud_network_private" {
  count = length(var.private_cidrs)
  vpc_id = aws_vpc.cloud_network.id
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = random_shuffle.az.result[count.index]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "cloud_network_public" {
  vpc_id = aws_vpc.cloud_network.id

  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_default_route_table" "cloud_network_private" {
  default_route_table_id = aws_vpc.cloud_network.default_route_table_id

  tags = {
    Name = "Private_Subnet"
  }
}

resource "aws_internet_gateway" "cloud_network_igw" {
  vpc_id = aws_vpc.cloud_network.id

  tags = {
    Name = "cloud_network_igw"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.cloud_network_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.cloud_network_igw.id
}

resource "aws_route_table_association" "cloud_network_public" {
  count = length(var.public_cidrs)
  subnet_id = aws_subnet.cloud_network_public.*.id[count.index]
  route_table_id = aws_route_table.cloud_network_public.id
}

resource "aws_security_group" "cloud_network_public" {
  name = "Public_Subnet"
  vpc_id = aws_vpc.cloud_network.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "cloud_network_public" {
  for_each = var.security_group_public
  security_group_id = aws_security_group.cloud_network_public.id
  type = each.value.type
  from_port = each.value.from
  to_port = each.value.to
  protocol = each.value.protocol
  cidr_blocks = each.value.cidrs
}

