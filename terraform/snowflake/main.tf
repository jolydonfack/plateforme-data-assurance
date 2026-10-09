# Test de connexion : liste les bases visibles, sans lire leurs détails ni
# leurs paramètres (la base système SNOWFLAKE n'est pas inspectable par SYSADMIN)
data "snowflake_databases" "all" {
  with_describe   = false
  with_parameters = false
}

output "snowflake_databases_visibles" {
  value = [for db in data.snowflake_databases.all.databases : db.show_output[0].name]
}
