# versão Terraform e versão provider AWS
terraform {
  required_version = "1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }
}
# Configurações do provider AWS - região e perfil(.aws/credentials)
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
