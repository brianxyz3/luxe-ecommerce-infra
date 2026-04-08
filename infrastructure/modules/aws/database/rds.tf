resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "rds_db" {
  engine                              = "postgres"
  engine_version                      = "17.6"
  instance_class                      = "db.t4g.micro"
  identifier                          = "${var.project_name}-rds-db-instance"
  db_name                             = "luxedb"
  username                            = "luxeadmin"
  manage_master_user_password         = true
  allocated_storage                   = 20
  storage_type                        = "gp3"
  db_subnet_group_name                = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids              = [var.rds_sg_id]
  iam_database_authentication_enabled = true
  storage_encrypted                   = true
  max_allocated_storage               = 100
  multi_az                            = false
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  backup_retention_period             = 7
  blue_green_update {
    enabled = true
  }
}

resource "aws_secretsmanager_secret_rotation" "name" {
  secret_id = aws_db_instance.rds_db.master_user_secret[0].secret_arn

  rotation_rules {
    automatically_after_days = 7
  }
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/${var.project_name}/${var.env}/database/rds_endpoint"
  type  = "SecureString"
  value = aws_db_instance.rds_db.endpoint
}

resource "aws_ssm_parameter" "rds_db_name" {
  name  = "/${var.project_name}/${var.env}/database/rds_db_name"
  type  = "String"
  value = aws_db_instance.rds_db.db_name
}

resource "aws_ssm_parameter" "rds_db_secret_arn" {
  name  = "/${var.project_name}/${var.env}/database/rds_db_secret_arn"
  type  = "SecureString"
  value = aws_db_instance.rds_db.master_user_secret[0].secret_arn
}