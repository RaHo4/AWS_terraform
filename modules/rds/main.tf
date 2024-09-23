resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group
  subnet_ids  = var.subnet_ids
  tags = {
    Name = var.db_subnet_group
  }
}

resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az             = var.multi_az
  availability_zone    = var.availability_zone
  apply_immediately    = var.apply_immediately

  tags = var.tags

  storage_encrypted = true
  backup_retention_period = 7
  skip_final_snapshot = true
}
