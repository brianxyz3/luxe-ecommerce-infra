output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "tg_arn" {
  value = {
    for key, tg in aws_alb_target_group.ecs-tg : key => tg.arn
  }
}

output "priv_subnet_ids" {
  value = aws_subnet.private-subnets[*].id
}

output "db_subnet_ids" {
  value = aws_subnet.db-subnets[*].id
}

output "alb_arn" {
  value = aws_alb.alb.arn
}