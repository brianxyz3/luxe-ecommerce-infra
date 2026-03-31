resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds_db" {
  engine = "postgres"
  engine_version = "17.6"
  instance_class = "db.t4g.micro"
  identifier = "${var.project_name}-rds-db-instance"
  allocated_storage = 20
  storage_type = "gp3"
  db_name = "${var.project_name}-rds-db"
  username = "admin"
  password = "password123" # In production, use a secure method to manage secrets
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  iam_database_authentication_enabled = true
  storage_encrypted = true
  max_allocated_storage = 100
  multi_az = false
  publicly_accessible = false
}