# SG: instancias, Mount Targets, RDS, Load Balancer, Bastion Host
# Instancias do AutoScaling Group
resource "aws_security_group" "SG-instances" {
  name        = "SG-instancias"
  description = "SG instancias AutoScaling"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description     = "SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-bastion.id]
  }
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-load-balancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-Instancias"
  }
}
# Instancia Bastion Host
resource "aws_security_group" "SG-bastion" {
  name        = "SG-bastion"
  description = "SG Bastion Host"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-Bastion"
  }
}
# RDS - Banco de Dados
resource "aws_security_group" "SG-rds" {
  name        = "SG-rds"
  description = "SG Banco de dados RDS"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description     = "MYSQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-instances.id]
  }

  ingress {
    description     = "MYSQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-RDS"
  }
}
# Mount Targets (EFS)
resource "aws_security_group" "SG-mount-target" {
  name        = "SG-mount-target"
  description = "SG dos Mount Targets do EFS"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-instances.id]
  }
  ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.SG-bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-Mount-Target"
  }
}
# Load Balancer
resource "aws_security_group" "SG-load-balancer" {
  name        = "SG-load-balancer"
  description = "SG do LoadBalancer"
  vpc_id      = aws_vpc.vpc-wordpress.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG-Load-Balancer"
  }
}