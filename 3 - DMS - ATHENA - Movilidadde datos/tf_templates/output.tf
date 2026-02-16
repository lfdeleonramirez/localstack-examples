output "debug_vpc_id" {
  value = module.networking.vpc_id
  description = "ID de la VPC creada"
}

output "debug_db_endpoint" {
  value = module.database.db_endpoint
  description = "Endpoint de escritura de Aurora"
}

output "debug_secret_arn" {
  value = module.database.db_secret_arn
  description = "ARN del secreto en Secrets Manager (DMS lo usará)"
}

output "debug_s3_bucket" {
  value = module.datalake.s3_bucket_name
  description = "Nombre del bucket S3 destino"
}