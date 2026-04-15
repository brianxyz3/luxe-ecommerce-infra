resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.${count.index + 20}.0/24"
  availability_zone = "${var.region}${count.index % 2 == 0 ? "a" : "b"}"


  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}-${count.index % 2 == 0 ? "a" : "b"}"
  }
}


resource "aws_route_table" "priv_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-priv-subnets-rt"
  }
}

resource "aws_vpc_peering_connection" "app_vpc_peer" {
  vpc_id = aws_vpc.vpc.id
  peer_vpc_id = data.aws_ssm_parameter.peer_vpc_id.value
  peer_region = var.region
  auto_accept = false

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "VPC Peering between luxe-ecormmerce-app and ${var.project_name} vpcs"
    Side = "Requester"
  }
}

resource "aws_route" "vpc_peer_route" {
  route_table_id            = aws_route_table.priv_rt.id
  vpc_peering_connection_id = aws_vpc_peering_connection.app_vpc_peer.id
  destination_cidr_block = data.aws_ssm_parameter.peer_vpc_cidr.value
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [
    aws_route_table.priv_rt.id
  ]
}
resource "aws_ssm_parameter" "vpc_peer_id" {
  name  = "/${var.project_name}/${var.env}/network/vpc/analyticsxcore_vpc_peer_id"
  type  = "String"
  value = aws_vpc_peering_connection.app_vpc_peer.id
}