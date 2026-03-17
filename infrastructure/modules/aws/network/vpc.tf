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
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.${count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}

resource "aws_subnet" "private-subnets" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${count.index + 10}.0/24"
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"
  
  map_public_ip_on_launch = true # DELETE AFTER TESTING


  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}

resource "aws_subnet" "db-subnets" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.10.${count.index + 20}.0/24"
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"
  

  tags = {
    Name = "${var.project_name}-db-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-public-subnets-rt"
  }
}

# resource "aws_route_table" "priv-rt" {
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "${var.project_name}-private-subnets-rt"
#   }
# }

resource "aws_route" "igw-route" {
  route_table_id         = aws_route_table.pub-rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# resource "aws_route" "nat-route" {
#   route_table_id         = aws_route_table.priv-rt.id
#   gateway_id             = aws_nat_gateway.nat.id
#   destination_cidr_block = "0.0.0.0/0"
# }

resource "aws_route_table_association" "public-rt" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "private-rt" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.pub-rt.id # CHANGE TO priv-rt.id AFTER TESTING
}

resource "aws_vpc_endpoint" "dynamo_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids   = [aws_route_table.pub-rt.id] # CHANGE TO priv-rt.id AFTER TESTING
  # "Gateway" is the default vpc_endpoint_type in Terraform so no need to specify it here

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAccessToLuxeDBTable"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.dynamo_db_arn,
          "${var.dynamo_db_arn}/index/*"
        ]
      }
    ]
  })

}

resource "aws_vpc_endpoint" "jdbc_endpoint" {
  count = var.subnet_count
  vpc_id = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  subnet_ids = [ aws_subnet.db-subnets[count.index].id ]
}