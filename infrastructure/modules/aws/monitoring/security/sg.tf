resource "aws_security_group" "grafana_sg" {
  name   = "grafana-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "security group rule for grafana"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "security group rule for ssh"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "project" = "${var.project_name}"
  }
}

# resource "aws_security_group" "sg" {
#   name = "${var.project_name}-${var.team_name}-sg"
#   vpc_id = var.vpc_id

#   ingress {
#     from_port = 3000
#     to_port = 3000
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "security group rule for grafana"
#   }

#   ingress {
#     from_port = 9090
#     to_port = 9090
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "security group rule for prometheus"
#   }

#   ingress {
#     from_port = 3100
#     to_port = 3100
#     protocol = "tcp"
#     cidr_blocks = [ "0.0.0.0/0" ]
#     description = "security group rule for loki"
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [ "0.0.0.0/0" ]
#   }
# }