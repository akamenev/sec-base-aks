resource "azurerm_container_registry" "sec-aks-acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  location            = azurerm_resource_group.fw-hub-aks.location
  sku                 = "Premium"
  admin_enabled       = false
  network_rule_set {
    default_action = "Deny"
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.aks-subnet.id
    }
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.mgmt-subnet.id
    }
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.build-agents.id
    }

  }
}