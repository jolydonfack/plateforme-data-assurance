terraform {
  required_version = ">= 1.9"
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.21"
    }
  }
  backend "azurerm" {}
}

# Connexion par clé : organisation, compte, utilisateur et clé privée
# sont lus dans les variables d'environnement SNOWFLAKE_*
provider "snowflake" {
  authenticator = "SNOWFLAKE_JWT"
  role          = "SYSADMIN"
}
