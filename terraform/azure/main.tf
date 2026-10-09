locals {
  tags = {
    projet = "assurance"
    env    = var.env
    owner  = "joly.donfack"
  }
}

# Test de connexion : lit l'identité utilisée par Terraform, ne crée rien
data "azurerm_client_config" "current" {}

output "azure_subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
