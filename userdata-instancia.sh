# Script de User-data para fazer a AMI - que vai ser usada nas instancias do Autoscaling(LaunchTemplate)
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
sudo echo 'id_EFS   /home/ec2-user/efs    efs     defaults,_netdev    0   0' | sudo tee -a /etc/fstab
sudo mount -a
# Cria o docker-compose.yaml
sudo mkdir /home/ec2-user/docker-compose
sudo echo -e "version: '3.1'\n 
services:\n
  wordpress:\n
    image: wordpress:5.6.0-php7.4\n
    restart: always\n
    ports:\n
      - 80:80\n
    volumes:\n
      - /home/ec2-user/efs:/var/www/html \n
    env_file:\n
      - /home/ec2-user/efs/wp.env\n
" | sudo tee /home/ec2-user/docker-compose/docker-compose.yml
# Remove linhas em branco do arquivo
sudo sed -i '/^$/d' docker-compose.yml