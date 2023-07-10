# key pair
resource "aws_key_pair" "KEY-wordpress" {
  key_name   = "key-wordpress"
  public_key = file("./chaves/${var.public_key}")
}

# Instancia bastion host
resource "aws_instance" "EC2-bastion-host" {
  ami                         = "ami-04823729c75214919"
  associate_public_ip_address = true 
  availability_zone           = "us-east-1a"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.KEY-wordpress.key_name
  vpc_security_group_ids      = [aws_security_group.SG-bastion.id]
  subnet_id                   = aws_subnet.sub-public-1a.id
  user_data = templatefile("../userdata-instancia.sh", {
    ID_EFS       = aws_efs_file_system.efs-wordpress.id,
    ENDPOINT_RDS = aws_db_instance.RDS-wordpress.endpoint
  })

  tags = {
    Name       = "PB Senac"
    CostCenter = "C092000004"
    Project    = "PB Senac"
  }
  volume_tags = {
    Name       = "PB Senac"
    CostCenter = "C092000004"
    Project    = "PB Senac"
  }
}

# AMI
resource "aws_ami_from_instance" "AMI-wordpress" {
  name               = "AMI-wordpress"
  source_instance_id = aws_instance.EC2-bastion-host.id
}


