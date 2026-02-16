# --- Generacion de password aleatoria
resource "random_password" "master" {
  length = 16
  special = true
  override_special = "_!%^"
}

resource "random_id" "suffix" { byte_length = 4 }

resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.project_name}-aurora-creds-${random_id.suffix.hex}"
  description = "Credenciales maestras para Aurora PostgreSQL"
  recovery_window_in_days = 0 
}

resource "aws_secretsmanager_secret_version" "db_secret_val" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "postgres_admin"
    password = random_password.master.result
    engine = "postgres"
    host = aws_rds_cluster.postgresql.endpoint
    port = 5432
    dbname = "master_db"
  })
}

resource "aws_db_subnet_group" "aurora" {
  name = "${var.project_name}-db-subnet"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-db-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = [var.vpc_cidr] # Permitir acceso interno VPC
  }
}

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier = "${var.project_name}-aurora"
  engine = "aurora-postgresql"
  engine_mode = "provisioned"
  engine_version = "15.4"
  database_name = "master_db"
  master_username = "postgres_admin"
  master_password = random_password.master.result # Referencia interna
  db_subnet_group_name = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "writer" {
  identifier = "${var.project_name}-writer"
  cluster_identifier = aws_rds_cluster.postgresql.id
  instance_class = var.db_instance_class 
  engine = aws_rds_cluster.postgresql.engine
  engine_version = aws_rds_cluster.postgresql.engine_version
  publicly_accessible = false
}