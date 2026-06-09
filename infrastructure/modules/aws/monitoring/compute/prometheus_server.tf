resource "aws_instance" "prometheus" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  security_groups = [ var.prometheus_sg_id ]
  key_name        = "monitoring_kp"
  user_data = file("/scripts/prometheus_setup.sh")

  tags = {
    "Name" = "${var.project_name}-prometheus"
  }

  lifecycle {
    ignore_changes = all
  }
}