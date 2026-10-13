resource "azurerm_storage_queue" "snowpipe" {
  name               = "snowpipe-landing"
  storage_account_id = azurerm_storage_account.lz.id
}

resource "azurerm_eventgrid_system_topic" "lz" {
  name                = "egst-assurance-lz-${var.env}"
  resource_group_name = azurerm_resource_group.data.name
  location            = azurerm_resource_group.data.location
  source_resource_id  = azurerm_storage_account.lz.id
  topic_type          = "Microsoft.Storage.StorageAccounts"
  tags                = local.tags
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "eg_queue" {
  scope                = azurerm_storage_account.lz.id
  role_definition_name = "Storage Queue Data Message Sender"
  principal_id         = azurerm_eventgrid_system_topic.lz.identity[0].principal_id
}

resource "azurerm_role_assignment" "queue_admin" {
  scope                = azurerm_storage_account.lz.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = var.admin_object_id
}

resource "azurerm_eventgrid_system_topic_event_subscription" "landing" {
  name                 = "evs-landing-to-queue"
  system_topic         = azurerm_eventgrid_system_topic.lz.name
  resource_group_name  = azurerm_resource_group.data.name
  included_event_types = ["Microsoft.Storage.BlobCreated"]

  subject_filter {
    subject_begins_with = "/blobServices/default/containers/landing/"
  }

  advanced_filter {
    string_in {
      key    = "data.api"
      values = ["CopyBlob", "PutBlob", "PutBlockList", "FlushWithClose"]
    }
  }

  delivery_identity {
    type = "SystemAssigned"
  }

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.lz.id
    queue_name         = azurerm_storage_queue.snowpipe.name
  }

  depends_on = [azurerm_role_assignment.eg_queue]
}
