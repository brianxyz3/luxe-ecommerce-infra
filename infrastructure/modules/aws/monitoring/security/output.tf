output "grafana_sg_id" {
  value = aws_security_group.grafana_sg.id
}

output "prometheus_sg_id" {
  value = aws_security_group.prometheus_sg.id
}

output "loki_sg_id" {
  value = aws_security_group.loki_sg.id
}