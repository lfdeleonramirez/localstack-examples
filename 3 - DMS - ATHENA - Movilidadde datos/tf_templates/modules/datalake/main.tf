resource "random_id" "bucket_suffix" { byte_length = 4 }

#bucket con datos de dms en parquet
resource "aws_s3_bucket" "datalake" {
  bucket        = "${var.project_name}-raw-data-${random_id.bucket_suffix.hex}"
  force_destroy = true
}
# bucket para guardar resultados
resource "aws_s3_bucket" "athena" {
  bucket        = "${var.project_name}-athena-query-results-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# --- Athena ---
resource "aws_athena_workgroup" "analytics" {
  name = "dms-analytics-wg"
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena.bucket}/"
    }
  }
}

# Rol para acceder a DMS
resource "aws_iam_role" "dms_secrets_role" {
  name = "dms-secrets-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "dms.us-east-1.amazonaws.com" } 
    }]
  })
}

resource "aws_iam_policy" "dms_secrets_policy" {
  name = "dms-secrets-read-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["secretsmanager:GetSecretValue"]
      Resource = [var.source_secret_arn]
    },
    {
       Effect = "Allow",
       Action = ["kms:Decrypt"],
       Resource = "*" 
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dms_secrets_attach" {
  role       = aws_iam_role.dms_secrets_role.name
  policy_arn = aws_iam_policy.dms_secrets_policy.arn
}

# 2. Rol para que DMS escriba en S3
resource "aws_iam_role" "dms_s3_role" {
  name = "dms-s3-target-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "dms.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "dms_s3_inline" {
  name = "dms-s3-access"
  role = aws_iam_role.dms_s3_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:AbortMultipartUpload"]
      Resource = [aws_s3_bucket.datalake.arn, "${aws_s3_bucket.datalake.arn}/*"]
    }]
  })
}

# configuraciones para objetos utilizados en DMS
resource "aws_dms_replication_subnet_group" "dms" {
  replication_subnet_group_description = "DMS Subnets"
  replication_subnet_group_id = "dms-subnet-group"
  subnet_ids = var.private_subnet_ids
}

#Origen de dms - aurora
resource "aws_dms_endpoint" "source" {
  endpoint_id = "aurora-source-secret"
  endpoint_type = "source"
  engine_name = "aurora-postgresql"
  secrets_manager_arn = var.source_secret_arn
  secrets_manager_access_role_arn = aws_iam_role.dms_secrets_role.arn
  database_name = "master_db"
}

#Target s3 particionado por fechas
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "s3-target-partitioned"
  endpoint_type = "target"
  engine_name   = "s3"
  s3_settings {
    bucket_name = aws_s3_bucket.datalake.bucket
    service_access_role_arn = aws_iam_role.dms_s3_role.arn
    data_format = "parquet"
    date_partition_enabled  = true
    date_partition_sequence = "YYYYMMDD"
    date_partition_delimiter = "SLASH" 
  }
}

resource "aws_dms_replication_config" "serverless" {
  replication_config_identifier = "aurora-to-s3-serverless-task"
  resource_identifier = "aurora-to-s3-serverless-task"
  # Se realiza carga completa por ser temporal
  replication_type = "full-load"
  source_endpoint_arn = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn = aws_dms_endpoint.target.endpoint_arn
  compute_config {
    replication_subnet_group_id  = aws_dms_replication_subnet_group.dms.replication_subnet_group_id
    max_capacity_units           = 2
    min_capacity_units           = 1
    multi_az                     = false
  }
  table_mappings = jsonencode({
    rules = [{
        "rule-type" = "selection",
        "rule-id"   = "1",
        "rule-name" = "select-master-tables",
        "object-locator" = {
          "schema-name" = "public",
          "table-name"  = "master_%" 
        },
        "rule-action" = "include"
    }]
  })
}

#base de datos de glue
resource "aws_glue_catalog_database" "dms_catalog" {
  name = "${var.project_name}_catalog"
}

resource "aws_iam_role" "glue_crawler_role" {
  name = "glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue-s3-access"
  role = aws_iam_role.glue_crawler_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject"]
      Resource = ["${aws_s3_bucket.datalake.arn}/*"]
    }]
  })
}

resource "aws_glue_crawler" "dms_crawler" {
  database_name = aws_glue_catalog_database.dms_catalog.name
  name = "${var.project_name}-crawler"
  role = aws_iam_role.glue_crawler_role.arn
  s3_target {
    path = "s3://${aws_s3_bucket.datalake.bucket}/public/" # DMS crea la carpeta del esquema 'public'
  }
  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}