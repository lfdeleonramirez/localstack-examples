output "s3_bucket_name" { value = aws_s3_bucket.datalake.bucket }
output "glue_database_name" {
  value = aws_glue_catalog_database.dms_catalog.name
  description = "Nombre de la base de datos en Glue/Athena"
}

output "glue_crawler_name" {
  value = aws_glue_crawler.dms_crawler.name
  description = "Nombre del crawler que debes ejecutar tras la carga inicial"
}