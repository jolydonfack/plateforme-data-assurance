resource "azurerm_storage_account" "lz" {
  name                            = "stassurancelz${var.env}${local.kv_suffix}"
  resource_group_name             = azurerm_resource_group.data.name
  location                        = azurerm_resource_group.data.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  is_hns_enabled                  = true
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false
  tags                            = local.tags

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "c" {
  for_each              = toset(["landing", "archive", "rejets", "referentiels"])
  name                  = each.key
  storage_account_id    = azurerm_storage_account.lz.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "lz" {
  storage_account_id = azurerm_storage_account.lz.id
  rule {
    name    = "archive-froid-30j"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["archive/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
      }
    }
  }
  rule {
    name    = "rejets-suppression-90j"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["rejets/"]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }
}

resource "azurerm_role_assignment" "lz_admin" {
  scope                = azurerm_storage_account.lz.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.admin_object_id
}

resource "azurerm_monitor_diagnostic_setting" "lz_blob" {
  name                       = "diag-lz-blob-to-law"
  target_resource_id         = "${azurerm_storage_account.lz.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enabled_log {
    category_group = "audit"
  }
  enabled_metric {
    category = "Transaction"
  }
}
