module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "database" {
  source              = "./modules/database"
  project_name        = var.project_name
  vpc_id              = module.networking.vpc_id
  vpc_cidr            = var.vpc_cidr
  private_subnet_ids  = module.networking.private_subnet_ids
}

module "datalake" {
  source              = "./modules/datalake"
  project_name        = var.project_name
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  
  # Integración: Pasamos datos de la BD al Data Lake
  source_db_endpoint  = module.database.db_endpoint
  source_secret_arn   = module.database.db_secret_arn
}