resource "azurerm_resource_group" "data" {
  name     = "rg-assurance-data-${var.env}"
  location = var.location
  tags     = local.tags
}
