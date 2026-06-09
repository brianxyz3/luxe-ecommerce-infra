resource "aws_instance" "grafana" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_id
  security_groups = [var.grafana_sg_id]
  key_name        = "monitoring_kp"
  user_data = file("/scripts/grafana_setup.sh")


  tags = {
    "Name" = "${var.project_name}-grafana"
  }

  lifecycle {
    ignore_changes = all
  }
}