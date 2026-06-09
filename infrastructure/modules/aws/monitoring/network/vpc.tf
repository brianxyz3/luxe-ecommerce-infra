resource "aws_vpc" "vpc" {
  cidr_block           = "172.32.0.0/16"
  region               = var.region
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "172.32.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    "name"    = "monitoring_public_sub"
    "project" = "${var.project_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  region = var.region

  tags = {
    "name"    = "monitoring_igw"
    "project" = "${var.project_name}"
  }
}

# resource "aws_internet_gateway_attachment" "igw_att" {
#   vpc_id = aws_vpc.vpc.id
#   internet_gateway_id = aws_internet_gateway.igw.id
# }

# resource "aws_vpc_peering_connection" "vpc_conn" {
#   vpc_id = aws_vpc.vpc.id
#   peer_vpc_id = data.aws_ssm_parameter.core_vpc_id.value
#   auto_accept = true
# }

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "name"    = "monitoring_rt"
    "project" = "${var.project_name}"
  }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rt_assoc" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public.id
}

# resource "aws_ssm_parameter" "peer_id" {
#   name = "/${var.project_name}/${var.env}/network/vpc/observability_vpc_peer"
#   value = aws_vpc_peering_connection.vpc_conn.id
#   type = "String"
# }

# resource "aws_ssm_parameter" "vpc_cidr" {
#   name = "/${var.project_name}/${var.env}/network/vpc/observability_vpc_cidr"
#   value = aws_vpc.vpc.cidr_block
#   type = "String"
# }