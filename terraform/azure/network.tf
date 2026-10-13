resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-assurance-data-${var.env}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  address_space       = [var.vnet_cidr]
  tags                = local.tags
}

resource "azurerm_subnet" "pe" {
  name                              = "snet-pe"
  resource_group_name               = azurerm_resource_group.data.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = [cidrsubnet(var.vnet_cidr, 2, 0)]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "shir" {
  name                 = "snet-shir"
  resource_group_name  = azurerm_resource_group.data.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 2, 1)]
}

resource "azurerm_network_security_group" "pe" {
  name                = "nsg-assurance-pe-${var.env}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  tags                = local.tags
}

resource "azurerm_network_security_group" "shir" {
  name                = "nsg-assurance-shir-${var.env}"
  location            = azurerm_resource_group.data.location
  resource_group_name = azurerm_resource_group.data.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.pe.id
}

resource "azurerm_subnet_network_security_group_association" "shir" {
  subnet_id                 = azurerm_subnet.shir.id
  network_security_group_id = azurerm_network_security_group.shir.id
}

locals {
  private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    dfs   = "privatelink.dfs.core.windows.net"
    queue = "privatelink.queue.core.windows.net"
    vault = "privatelink.vaultcore.azure.net"
    adf   = "privatelink.datafactory.azure.net"
  }
}

resource "azurerm_private_dns_zone" "zone" {
  for_each            = local.private_dns_zones
  name                = each.value
  resource_group_name = azurerm_resource_group.data.name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each             = azurerm_private_dns_zone.zone
  name                 = "lnk-${each.key}-${var.env}"
  private_dns_zone_id  = each.value.id
  virtual_network_id   = azurerm_virtual_network.vnet.id
  registration_enabled = false
  tags                 = local.tags
}
