resource "azurerm_log_analytics_workspace" "container_insights" {
  name = "${var.cluster_name}-aks-logs"
  location = var.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  sku = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name = "Containers"
  location = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.container_insights.id
  workspace_name = azurerm_log_analytics_workspace.container_insights.name

  plan {
      publisher = "Microsoft"
      product = "OMSGallery/Containers"
  }
}


resource "azurerm_log_analytics_workspace" "firewall-logs" {
  name = "${var.cluster_name}-fw-logs"
  location = var.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  sku = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "firewall-logs" {
  name               = "fw-logs"
  target_resource_id = azurerm_firewall.aks-hub-fw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.firewall-logs.id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = true
      days = 30
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = true
      days = 30
    }
  }
  
}