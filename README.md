# 2º Trabalho - Estágio AWS&DevSecOps - Compass Uol
2º trabalho - PB Compass UOL (AWS&DevSecOps) - Site Wordpress em contêiner Docker
## Índice:
  - [Descrição do Projeto](#descrição-do-projeto)
  - [Ambiente Infra AWS com Terraform](#ambiente-infra-aws-com-terraform)
  - [Ambiente Docker - Wordpress](#ambiente-docker---wordpress)
  - [Atributos Gerais](#atributos-gerais)
# Descrição do Projeto
Objetivo: Criar um ambiente na AWS, rodando um site Wordpress com Docker. 

**Esquema geral do Ambiente:** O tráfego de usuários entra pelo LoadBalancer e é direcionado para as instâncias web-server contendo o site Wordpress rodando em contêineres Docker. 
As instâncias se conectam ao um banco de dados Amazon RDS do site Wordpress.
![geral](https://github.com/MuriloScheunemann/Compass2-Docker-Wordpress/assets/122695407/f7d6c1d2-a4b4-4459-97f6-746c2efecb2e)
Um EFS é montado tanto nas instâncias web-server como no bastion host. Este EFS armazena os arquivos do site Wordpress e é montado no diretório /home/ec2-user/efs/. (Ver: [Árvore de diretórios](#árvore-de-diretórios))
![efs](https://github.com/MuriloScheunemann/Compass2-Docker-Wordpress/assets/122695407/c4a81663-8bd3-4b56-9d02-34499b80a778)
**Esquema geral de network:** Uma VPC com quatro subnets, duas públicas(bastion host e load balancer) e duas privadas (instâncias web-server), em duas AZs (us-east-1a e us-east-1b);
Um Internet Gateway roteado para as subnets públicas; um NAT Gateway roteado para as subnets privadas.
![rede](https://github.com/MuriloScheunemann/Compass2-Docker-Wordpress/assets/122695407/666581cd-6cd4-4ef5-aaaf-4654a923a957)
O tráfego do LoadBalancer é direcionado para as instâncias web-server nas subnets privadas, enquanto o NAT provê acesso outbound mas impede qualquer inbound de internet a essas instâncias. 
O administrador pode acessar o Bastion Host, na subnet publica,via IP público.
# Ambiente Infra AWS com Terraform
**Descrição:** no primeiro momento, cria-se a infraestrutura definindo o ***min_size*** e ***desired_size*** do Autoscaling em ***"0"***. Então, se pode acessar o bastion host e subir um conteiner Wordpress para configurar o site.
Após esta configuração, deleta-se o conteiner Wordpress. Então, o AutoScaling pode ser configurado para criar instancias web-server que iniciarão com as configurações de Wordpress prontas.
### Índice dos arquivos:
  - *[chaves](/terraform/chaves)* => diretório: contém a chave pública para criar key pair na AWS
  - *[autoscaling.tf](/terraform/autoscaling.tf)* => AutoScaling Group; Launch Configuration; Associação AutoScaling-Target Group
  - *[bastion-key-ami.tf](/terraform/bastion-key-ami.tf)* => Key pair; Bastion Host; AMI para o Launch Configuration
  - *[efs.tf](/terraform/efs.tf)* => Elastic File System; Mount Targets
  - *[lb-tg.tf](/terraform/lb-tg.tf)* => Application Load Balancer; Listener; Target Group
  - *[main.tf](/terraform/main.tf)* => Providers; credenciais AWS
  - *[outputs.tf](/terraform/outputs.tf)* => Saídas: DNS do Load Balancer; IP público do Bastion Host
  - *[rds.tf](/terraform/rds.tf)* => Instancia RDS; Grupo de Subnets do RDS
  - *[rede.tf](/terraform/rede.tf)* => VPC; Subnets; Internet Gateway; NAT gateway; Tabelas de roteamento; Associação entre tabelas e subnets
  - *[sec-gp.tf](/terraform/sec-gp.tf)* => Security Groups: Instancias(web-server), Bastion Host, RDS, Mount Targets, Load Balancer
  - *[terraform.tfvars](/terraform/terraform.tfvars)* => valores de entrada das variaveis do projeto
  - *[variables.tf](/terraform/variables.tf)* => declaração das variáveis
# Ambiente Docker - Wordpress
**Descrição:** o script "userdata-instancia.sh" é executado no bastion host. Cria-se uma AMI a partir do bastion host, que é usada no Launch Configuration nas instancias web-server. 
O script "userdata-launch-conf.sh" é executado nas instancias webserver do AutoScaling.
- *[userdata-instancia.sh](/userdata-instancia.sh)* => Instala Docker Engine e Docker-Compose; monta EFS; cria o arquivo docker-compose.yml.
- *[userdata-launch-conf.sh](/userdata-launch-conf.sh)* => inicia um conteiner docker-compose com o site Wordpress.
### docker-compose.yml:
**Arquivo [docker-compose.yml:](/docker-compose.yml)** 
- Cria um conteiner com a Docker Image do Wordpress mais recente. 
- Define as variáveis de ambiente do contêiner: 1. endpoint do RDS; 2. usuário; 3. senha; 4. nome do banco de dados. 
- Expõe o Wordpress, que fica na porta 80 do conteiner, na porta 80 da instância;
- Define uma montagem tipo 'bind' do diretório do EFS na instancia(/home/ec2-user/efs) para o diretório de configuração do Wordpress no conteiner(/var/www/html).
# Atributos gerais
## Network
- VPC => 10.0.0.0/16
- Subnets Publicas => 10.0.1.0/24; 10.0.2.0/24
- Subnets Privadas => 10.0.3.0/24; 10.0.4.0/24
## Instancias
- Bastion Host
  - t3.micro
  - 1x EBS gp3 - 8GB
  - Amazon Linux 2
  - us-east-1a | subnet pública
- Instancias Web-server
  - t3.small
  - 1x EBS gp3 - 8GB
  - AMI personalizada
  - us-east-1; us-east-1b; | subnets privadas
## RDS
  - db.t3.micro
  - Versão DB Engine: 8.0.32 - Mysql
  - SSD gp2 - 20GB
  - Multi-AZ: não
  - Publicamente acessivel: não
## AutoScaling Group
  - Min. => 2
  - Desired => 2
  - Max. => 4
## Application Load Balancer
  - Listener: HTTP/80 - Forward to target group
  - Algoritmo: Round-Robin
## Security Groups
- Instâncias Web-Server:

|     Type      |   Protocol    |   Port Range   |   Source        | 
| ------------- | ------------- | -------------- | --------------- |
|      SSH      |      TCP      |       22       | SG-Bastion-Host |
|      HTTP     |      TCP      |       80       | SG-Load-Balancer|
- Bastion Host:

|     Type      |   Protocol    |   Port Range   |   Source        | 
| ------------- | ------------- | -------------- | --------------- |
|      SSH      |      TCP      |       22       |    ADMIN-IP     |
|      HTTP     |      TCP      |       80       |    ADMIN-IP     |
- Load Balancer:

|     Type      |   Protocol    |   Port Range   |   Source        | 
| ------------- | ------------- | -------------- | --------------- |
|      HTTP     |      TCP      |       80       |    0.0.0.0/0    |
- RDS:

|     Type      |   Protocol    |   Port Range   |   Source        | 
| ------------- | ------------- | -------------- | --------------- |
|      Mysql    |      TCP      |       3306     | SG-Web-Servers  |
|      Mysql    |      TCP      |       3306     | SG-Bastion-Host |  
- Mount Targets:

|     Type      |   Protocol    |   Port Range   |   Source        | 
| ------------- | ------------- | -------------- | --------------- |
|      NFS      |      TCP      |       2049     | SG-Web-Servers  |
|      NFS      |      TCP      |       2049     | SG-Bastion-Host | 
### Árvore de diretórios:
![arvore-diretorios](https://github.com/MuriloScheunemann/Compass2-Docker-Wordpress/assets/122695407/39793f97-c221-47a5-9558-b7884b08a0c7)
