resource "azurerm_kubernetes_cluster" "akscni" {
  name                = var.cluster_name
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  linux_profile {
    admin_username = var.username

    ssh_key {
      key_data = file("${var.ssh_public_key}")
    }
  }
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name               = "default"
    node_count         = 3
    vm_size            = "Standard_D2_v2"
    os_disk_size_gb    = 120
    max_pods           = 30
    vnet_subnet_id     = azurerm_subnet.aks-subnet.id
    type               = "VirtualMachineScaleSets"
    availability_zones = ["1", "2", "3"]
  }

  private_cluster_enabled = true

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.10.0.0/24"
    dns_service_ip     = "10.10.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
    load_balancer_sku  = "standard"
    outbound_type      = "userDefinedRouting"
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.container_insights.id
    }
  }

  depends_on = [
    azurerm_subnet_route_table_association.fw-route-asc
  ]

}

resource "azurerm_kubernetes_cluster_node_pool" "system" {
  name                  = "system"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.akscni.id
  vm_size               = "Standard_D2_v2"
  node_count            = 3
  os_disk_size_gb       = 120
  max_pods              = 30
  vnet_subnet_id        = azurerm_subnet.aks-subnet.id
  availability_zones    = ["1", "2", "3"]
  mode                  = "System"
}

# associate a private DNS with a hub vnet
resource "azurerm_private_dns_zone_virtual_network_link" "fw-hub-aks-dns" {
  name                  = "aks-dns"
  resource_group_name   = azurerm_kubernetes_cluster.akscni.node_resource_group
  private_dns_zone_name = trimprefix(azurerm_kubernetes_cluster.akscni.private_fqdn, regex(".*?\\.", azurerm_kubernetes_cluster.akscni.private_fqdn)) # removing all chars before the first dot to match the Private DNS zone name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
}
