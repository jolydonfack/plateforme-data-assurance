locals {
  env_up = upper(var.env)
}

resource "snowflake_database" "db" {
  name                        = "ASSURANCE_${local.env_up}"
  data_retention_time_in_days = var.env == "prod" ? 7 : 1
  comment                     = "Plateforme data Assurance - ${var.env}"
}

resource "snowflake_schema" "s" {
  for_each            = toset(["BRONZE", "SILVER", "GOLD", "SECURITY", "MONITORING"])
  database            = snowflake_database.db.name
  name                = each.key
  with_managed_access = "true"
}

resource "snowflake_warehouse" "wh" {
  for_each            = toset(["INGEST", "TRANSFORM", "BI", "RAG"])
  name                = "WH_${each.key}_${local.env_up}"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  auto_resume         = "true"
  initially_suspended = true
  comment             = "Entrepot ${lower(each.key)} - ${var.env}"
}
