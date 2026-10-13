locals {
  kv_suffix = substr(md5(data.azurerm_client_config.current.subscription_id), 0, 5)
}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-assurance-${var.env}-${local.kv_suffix}"
  location                      = azurerm_resource_group.data.location
  resource_group_name           = azurerm_resource_group.data.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = var.env == "prod" ? 90 : 7
  purge_protection_enabled      = var.env == "prod"
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_object_id
}

resource "azurerm_role_assignment" "kv_pipeline" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "diag-kv-to-law"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enabled_log {
    category_group = "audit"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}
