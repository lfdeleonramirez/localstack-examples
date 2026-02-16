# variables.tf

variable "aws_region" {
  description = "Región de AWS para el despliegue"
  type = string
  default = "us-east-1"
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
variable "project_id" {
  description = "Tag: ID del proyecto"
  type = string
  default = "202602-APP-MESH"
}

variable "project_area" {
  description = "Tag: Area responsable"
  type = string
  default = "Infraestructura Cloud"
}

variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type = string
  default = "10.0.0.0/16"
  
  validation {
    condition = can(cidrnetmask(var.vpc_cidr)) && length(split("/", var.vpc_cidr)) == 2
    error_message = "El CIDR debe ser una dirección IPv4 válida en formato CIDR (ej: 10.0.0.0/16)."
  }
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM existente para mTLS"
  type = string
  default= "arn:aws:acm::123456789012:certificate/CertificadoProduccion2026"
  validation {
    condition = can(regex("^arn:aws:acm:.*:certificate/.*", var.acm_certificate_arn))
    error_message = "Debe proporcionar un ARN de ACM válido."
  }
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