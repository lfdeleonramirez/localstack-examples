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

variable "project_id" {
  description = "Tag: ID del proyecto"
  type = string
  default = "202602-ENV-EKS"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "node_group_instance" {
  description = "Tipo de instancia del nodegroup"
  type=string
  default ="t3.medium"
  validation {
    condition = can(regex("^(t3|m5|c5)", var.node_group_instance))
    error_message = "Solo familias t3, m5 o c5 permitidas."
  }
}

variable "k8s_service_account_name" {
  default = "s3-service-account"
}

variable "k8s_namespace" {
  default = "microservicios"
}

variable "s3_name" {
  default="s3-prod"
}