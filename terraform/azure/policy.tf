data "azurerm_policy_definition_built_in" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition_built_in" "require_tag" {
  display_name = "Require a tag on resources"
}

data "azurerm_policy_definition_built_in" "storage_public" {
  display_name = "Storage account public access should be disallowed"
}

resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "pa-allowed-locations"
  resource_group_id    = azurerm_resource_group.data.id
  policy_definition_id = data.azurerm_policy_definition_built_in.allowed_locations.id
  parameters = jsonencode({
    listOfAllowedLocations = { value = [var.location] }
  })
}

resource "azurerm_resource_group_policy_assignment" "require_tag" {
  for_each             = toset(["projet", "env", "owner"])
  name                 = "pa-tag-${each.key}"
  resource_group_id    = azurerm_resource_group.data.id
  policy_definition_id = data.azurerm_policy_definition_built_in.require_tag.id
  parameters = jsonencode({
    tagName = { value = each.key }
  })
}

resource "azurerm_resource_group_policy_assignment" "storage_public" {
  name                 = "pa-storage-no-public"
  resource_group_id    = azurerm_resource_group.data.id
  policy_definition_id = data.azurerm_policy_definition_built_in.storage_public.id
  parameters = jsonencode({
    effect = { value = "deny" }
  })
}