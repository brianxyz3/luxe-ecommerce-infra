resource "aws_vpc" "vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}


resource "aws_subnet" "public-subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}

resource "aws_subnet" "private-subnets" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${count.index + 10}.0/24"
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-public-subnets-rt"
  }
}

resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-private-subnets-rt"
  }
}

resource "aws_route" "igw-route" {
  route_table_id         = aws_route_table.pub-rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "nat-route" {
  route_table_id         = aws_route_table.priv-rt.id
  gateway_id             = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public-rt" {
  count          = 2
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "private-rt" {
  count          = 2
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.priv-rt.id
}