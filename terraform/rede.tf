# VPC
resource "aws_vpc" "vpc-wordpress" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true  #Para poder montar o EFS
  tags = {
    "Name" = "VPC-wordpress"
  }
}

# Subnets
resource "aws_subnet" "sub-public-1a" {
  vpc_id            = aws_vpc.vpc-wordpress.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name" = "SUB-public-1a"
  }
}
resource "aws_subnet" "sub-public-1b" {
  vpc_id            = aws_vpc.vpc-wordpress.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"
  tags = {
    "Name" = "SUB-public-1b"
  }
}
resource "aws_subnet" "sub-private-1a" {
  vpc_id            = aws_vpc.vpc-wordpress.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.3.0/24"
  tags = {
    "Name" = "SUB-private-1a"
  }
}
resource "aws_subnet" "sub-private-1b" {
  vpc_id            = aws_vpc.vpc-wordpress.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.4.0/24"
  tags = {
    "Name" = "SUB-private-1b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-wordpress.id
  tags = {
    Name = "IGW-wordpress"
  }
}

# IP elástico (necessario para o NAT gateway)
resource "aws_eip" "elastic-ip-nat" {
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic-ip-nat.allocation_id
  subnet_id     = aws_subnet.sub-public-1a.id
  tags = {
    Name = "NAT-wordpress"
  }
}

# Tabelas de Rotamento
resource "aws_route_table" "tab-pub-wordpress" {
  vpc_id = aws_vpc.vpc-wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "RouteTable-Public-wordpress"
  }
}
resource "aws_route_table" "tab-priv-wordpress" {
  vpc_id = aws_vpc.vpc-wordpress.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "RouteTable-Private-wordpress"
  }
}

# Associações das subnets as tabelas de rotas
resource "aws_route_table_association" "public-1a-route-asssociation" {
  subnet_id      = aws_subnet.sub-public-1a.id
  route_table_id = aws_route_table.tab-pub-wordpress.id
}
resource "aws_route_table_association" "public-1b-route-asssociation" {
  subnet_id      = aws_subnet.sub-public-1b.id
  route_table_id = aws_route_table.tab-pub-wordpress.id
}
resource "aws_route_table_association" "private-1a-route-association" {
  subnet_id      = aws_subnet.sub-private-1a.id
  route_table_id = aws_route_table.tab-priv-wordpress.id
}
resource "aws_route_table_association" "private-1b-route-association" {
  subnet_id      = aws_subnet.sub-private-1b.id
  route_table_id = aws_route_table.tab-priv-wordpress.id
}