# Instancia RDS
resource "aws_db_instance" "RDS-wordpress" {
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.RDS-subnet-group.name
  identifier             = "rds-wordpress"
  allocated_storage      = 20
  db_name                = "wordpress"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  username               = var.rds_user
  password               = var.rds_password
  vpc_security_group_ids = [aws_security_group.SG-rds.id]
  skip_final_snapshot    = true
}

# Grupo de subnets do RDS (para associar o RDS à VPC)
resource "aws_db_subnet_group" "RDS-subnet-group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.sub-public-1a.id, aws_subnet.sub-private-1a.id, aws_subnet.sub-private-1b.id]
  tags = {
    Name = "RDS-subnet-group"
  }
}
