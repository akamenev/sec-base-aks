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

resource "azurerm_role_assignment" "acrpull" {
  scope                = azurerm_container_registry.sec-aks-acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.akscni.kubelet_identity.0.object_id

  depends_on = [
    azurerm_kubernetes_cluster.akscni
  ]
}