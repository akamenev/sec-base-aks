resource "azurerm_resource_group" "fw-hub-aks" {
  name     = var.resource_group_name
  location = var.location

}

resource "azurerm_virtual_network" "aks-vnet" {
  name                = "${var.cluster_name}-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
}

resource "azurerm_subnet" "aks-subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "10.0.8.0/22"
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "ingress-subnet" {
  name                 = "ingress-subnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "10.0.2.0/24"
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = "${var.cluster_name}-hub"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
}

resource "azurerm_subnet" "fw-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "192.168.1.0/26"
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

resource "azurerm_subnet" "mgmt-subnet" {
  name                 = "mgmt-subnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "192.168.2.0/24"
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "192.168.3.0/27"
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

resource "azurerm_subnet" "aux-subnet" {
  name                 = "aux-subnet"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "192.168.4.0/24"
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

resource "azurerm_subnet" "build-agents" {
  name                 = "build-agents"
  resource_group_name  = azurerm_resource_group.fw-hub-aks.name
  address_prefix       = "192.168.5.0/24"
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  service_endpoints    = ["Microsoft.ContainerRegistry"]
}


resource "azurerm_virtual_network_peering" "aks-hub" {
  name                      = "aks-hub"
  resource_group_name       = azurerm_resource_group.fw-hub-aks.name
  virtual_network_name      = azurerm_virtual_network.aks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_virtual_network_peering" "hub-aks" {
  name                      = "hub-aks"
  resource_group_name       = azurerm_resource_group.fw-hub-aks.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.aks-vnet.id
}
