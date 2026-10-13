resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-assurance-${var.env}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 1
  tags                = local.tags
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  count         = var.enable_defender_storage ? 1 : 0
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}
