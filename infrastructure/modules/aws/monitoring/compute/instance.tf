resource "aws_instance" "grafana" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_id
  security_groups = [var.grafana_sg_id]
  key_name        = "monitoring_kp"

  tags = {
    "Name" = "${var.project_name}-grafana"
  }
}

# resource "aws_instance" "name" {
#   ami = data.aws_ami_ids.ubuntu.id
#   instance_type = "t3.medium"
#   subnet_id = var.subnet_id
#   security_groups = [ var.sg_id ]
#   iam_instance_profile = 
# }