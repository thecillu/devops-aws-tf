resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.service_name}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.service_name}-public-subnet-${count.index}"
    Environment = var.environment
    Type = "Public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.service_name}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.service_name}-public-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = length(var.public_subnets)
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.service_name}-private-subnet-${count.index}"
    Environment = var.environment
    Type = "Private"
  }
}

resource "aws_eip" "nat_eip" {
  count = length(var.public_subnets)
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.service_name}-nat-eip-${count.index}"
    Environment = var.environment
  }
}


resource "aws_nat_gateway" "nat_gw" {
  count = length(var.public_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  tags = {
    Name = "${var.service_name}-nat-gw-${count.index}"
    Environment = var.environment
  }
}

resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

 tags = {
    Name = "${var.service_name}-private-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = length(var.private_subnets)
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_route_table[count.index].id
}