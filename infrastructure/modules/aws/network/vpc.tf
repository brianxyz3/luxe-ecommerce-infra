resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "private-subnets" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.${count.index + 20}.0/24"
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"


  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}


resource "aws_route_table" "priv-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-priv-subnets-rt"
  }
}

# data "aws_ssm_parameter" "peer-vpc-id" {
#   name = "/luxe-ecommerce/prod/network/vpc/id"
# }

# data "aws_ssm_parameter" "peer-vpc-cidr" {
#   name = "/luxe-ecommerce/prod/network/vpc/cidr"
# }

resource "aws_vpc_peering_connection" "app_vpc_peer" {
  vpc_id = aws_vpc.vpc.id
  # peer_vpc_id = data.aws_ssm_parameter.peer-vpc-id.value
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  peer_vpc_id = "99"
}

resource "aws_route" "vpc-peer-route" {
  route_table_id            = aws_route_table.priv-rt.id
  vpc_peering_connection_id = aws_vpc_peering_connection.app_vpc_peer.id
  # destination_cidr_block = data.aws_ssm_parameter.peer-vpc-cidr.value
  destination_cidr_block = "10.10.0.0/16"
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [
    aws_route_table.priv-rt.id
  ]
}