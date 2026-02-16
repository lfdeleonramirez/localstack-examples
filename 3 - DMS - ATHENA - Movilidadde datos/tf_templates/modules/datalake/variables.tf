variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "source_db_endpoint" { type = string }
variable "source_secret_arn" { 
  description = "ARN del secreto que contiene user/pass de la BD"
  type = string 
}