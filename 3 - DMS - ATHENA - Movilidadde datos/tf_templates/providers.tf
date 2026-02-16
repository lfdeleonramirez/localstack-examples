terraform {
  required_providers {
    aws={
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
    tls={
        source = "hashicorp/tls"
        version = "~> 4.0"
    }
  }
  required_version = ">= 1.5.0"
}
provider "aws" {
  region = var.aws_region
    #Estas estos datos se quedan por temas de pruebas en localstack, lo correcto es eliminarlo para que no queden registros de claves en los archivos
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key= "test"
  secret_key = "test"
  default_tags {
    tags = {
      Ambiente=var.environment
      Terraform="true"
      Area=var.project_area
      ID_Proyecto=var.project_name
    }
  }
   endpoints {
    ec2  = "http://localhost:4566"
    iam  = "http://localhost:4566"
    s3   = "http://localhost:4566"
    sts  = "http://localhost:4566"
  }
}