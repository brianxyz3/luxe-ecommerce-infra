resource "aws_security_group" "jdbc_sg" {
  name        = "${var.project_name}-jdbc"
  description = "allow traffic to jdbc"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_parameter" "rds_jdbc_sg_id" {
  name  = "/${var.project_name}/${var.env}/security/jdbc_sg_id"
  type  = "String"
  value = aws_security_group.jdbc_sg.id
}