resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public-subnets[0].id
  allocation_id = aws_eip.nat-eip.id

  tags = {
    Name = "${var.project_name}-nat"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}