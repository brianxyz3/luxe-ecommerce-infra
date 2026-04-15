output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "priv_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "priv_subnet_az" {
  value = aws_subnet.private_subnets[*].availability_zone
}