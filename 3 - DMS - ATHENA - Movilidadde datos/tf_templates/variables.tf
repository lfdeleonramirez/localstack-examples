variable "aws_region" {
  description = "Región de AWS"
  type = string
  default  = "us-east-1"
}
variable "environment" {
  description = "Entorno (desa, test, prod)"
  type = string
  default = "prod"
  validation {
    condition = contains(["desa", "test", "prod"], var.environment)
    error_message = "El ambiente debe ser 'desa', 'test' o 'prod'."
  }
}
variable "project_area" {
  description = "Tag: Area responsable"
  type = string
  default = "Infraestructura Cloud"
}


variable "project_name" {
  description = "Tag: ID del proyecto"
  type = string
  default = "dms-s3-rds-202602"
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type = string
  default = "10.0.0.0/16"
}
