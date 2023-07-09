# EFS
resource "aws_efs_file_system" "efs-wordpress" {
  tags = {
    Name = "EFS-wordpress"
  }
}
#Mount Targets                                      OBS: se o Bastion não conseguir montar é problema aqui
resource "aws_efs_mount_target" "mountTarget-1a" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.sub-private-1a.id
  security_groups = [aws_security_group.SG-mount-target.id]
}
resource "aws_efs_mount_target" "mountTarget-1b" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.sub-private-1b.id
  security_groups = [aws_security_group.SG-mount-target.id]
}