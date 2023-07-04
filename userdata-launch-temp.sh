# Script de user-data para o Launch Template do AutoScaling
#!/bin/bash
sudo yum update -y
sudo systemctl start docker
cd /home/ec2-user/docker-compose/
docker-compose up -d
