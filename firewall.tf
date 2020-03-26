resource "azurerm_public_ip" "fw-ip" {
  name                = "fw-ip"
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "aks-hub-fw" {
  name                = "aks-hub-fw"
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name

  ip_configuration {
    name                 = "ip-config"
    subnet_id            = azurerm_subnet.fw-subnet.id
    public_ip_address_id = azurerm_public_ip.fw-ip.id
  }
}


resource "azurerm_firewall_network_rule_collection" "fw-net-rule-1" {
  name                = "aks-fw-rule-1"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "dns"
    source_addresses = [
      "*",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

  }

}

resource "azurerm_firewall_network_rule_collection" "fw-net-rule-2" {
  name                = "aks-fw-rule-2"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "ntp"
    source_addresses = [
      "*",
    ]

    destination_ports = [
      "123",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

  }

}

resource "azurerm_firewall_network_rule_collection" "fw-net-rule-3" {
  name                = "aks-fw-rule-3"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 300
  action              = "Allow"

  rule {
    name = "aks-tcp"
    source_addresses = [
      "*",
    ]

    destination_ports = [
      "22",
      "9000",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]

  }

}

resource "azurerm_firewall_network_rule_collection" "fw-net-rule-4" {
  name                = "aks-fw-rule-4"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 400
  action              = "Allow"

  rule {
    name = "aks-udp"
    source_addresses = [
      "*",
    ]

    destination_ports = [
      "1194",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]

  }

}

resource "azurerm_firewall_application_rule_collection" "fw-app-rule" {
  name                = "aks-app-rule"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "AKS"

    source_addresses = [
      "*",
    ]

    target_fqdns = [
      "*.hcp.eastus.azmk8s.io", # AKS Required
      "*.tun.eastus.azmk8s.io",
      "*.cdn.mscr.io",
      "mcr.microsoft.com",
      "*.data.mcr.microsoft.com",
      "management.azure.com",
      "login.microsoftonline.com",
      "ntp.ubuntu.com",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net",
      "security.ubuntu.com", # Recommended for Security OS patches
      "azure.archive.ubuntu.com",
      "changelogs.ubuntu.com",
      "dc.services.visualstudio.com", # Required for Azure Monitor for Containers
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.microsoftonline.com",
      "*.monitoring.azure.com",
      "gov-prod-policy-data.trafficmanager.net", # Required for Azure Policy for AKS
      "raw.githubusercontent.com",
      "*.gk.eastus.azmk8s.io",
      "dc.services.visualstudio.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }

  }

}

resource "azurerm_route_table" "fw-route-table" {
  name                = "fw-route-table"
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name

  route {
    name                   = "fw-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.aks-hub-fw.ip_configuration.0.private_ip_address
  }

}

resource "azurerm_subnet_route_table_association" "fw-route-asc" {
  subnet_id      = azurerm_subnet.aks-subnet.id
  route_table_id = azurerm_route_table.fw-route-table.id
}

resource "azurerm_firewall_nat_rule_collection" "ssh-jump" {
  name                = "ssh-jump"
  azure_firewall_name = azurerm_firewall.aks-hub-fw.name
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "ssh-jump"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "22",
    ]

    destination_addresses = [
      azurerm_public_ip.fw-ip.ip_address,
    ]
    
    translated_address = azurerm_linux_virtual_machine.jumpbox.private_ip_address
    translated_port = "22"

    protocols = [
      "TCP",
    ]
  }
}
