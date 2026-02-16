variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_instance_class" {
  description = "Clase de instancia para el cluster Aurora"
  type        = string
  default     = "db.t3.medium"
}