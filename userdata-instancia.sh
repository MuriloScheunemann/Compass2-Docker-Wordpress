#!/bin/bash
# Instalar Docker-CE ( Container Engine): 
sudo yum update
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
# Instalar Docker Compose:
sudo curl -SL https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# EFS
sudo yum install amazon-efs-utils -y
sudo mkdir -m 666 /home/ec2-user/efs
sudo echo "${ID_EFS}   /home/ec2-user/efs    efs     defaults,_netdev    0   0" | sudo tee -a /etc/fstab
sudo mount -a
# Cria o docker-compose.yaml
sudo mkdir /home/ec2-user/docker-compose
sudo echo -e "version: '3.1'\n 
services:\n
  wordpress:\n
    image: wordpress:latest\n        
    restart: always\n
    ports:\n
      - 80:80\n
    environment:\n
      WORDPRESS_DB_HOST: ${ENDPOINT_RDS}\n
      WORDPRESS_DB_USER: admin\n
      WORDPRESS_DB_PASSWORD: 12345678\n
      WORDPRESS_DB_NAME: wordpress\n
    volumes:\n
      - /home/ec2-user/efs:/var/www/html\n
" | sudo tee /home/ec2-user/docker-compose/docker-compose.yml
sudo sed -i '/^$/d' /home/ec2-user/docker-compose/docker-compose.yml
