output "db_endpoint" { value = aws_rds_cluster.postgresql.endpoint }
output "db_secret_arn" { value = aws_secretsmanager_secret.db_secret.arn }