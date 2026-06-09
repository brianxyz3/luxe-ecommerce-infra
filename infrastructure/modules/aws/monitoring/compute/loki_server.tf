resource "aws_instance" "loki" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  security_groups = [ var.loki_sg_id ]
  key_name        = "monitoring_kp"
  user_data = file("/scripts/loki_setup.sh")

  tags = {
    "Name" = "${var.project_name}-loki"
  }

  lifecycle {
    ignore_changes = all
  }
}