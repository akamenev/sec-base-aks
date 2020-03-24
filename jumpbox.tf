resource "azurerm_network_interface" "jump-nic" {
  name                = "jump-nic"
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name

  ip_configuration {
    name                          = "jump-config"
    subnet_id                     = azurerm_subnet.mgmt-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "jumpbox"
  location            = azurerm_resource_group.fw-hub-aks.location
  resource_group_name = azurerm_resource_group.fw-hub-aks.name
  size                = "Standard_F2"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.jump-nic.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file("${var.ssh_public_key}")
  }

  os_disk {
    name                 = "jumpbox-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 120
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "azure-cli" {
  name                 = "azure-cli-install"
  virtual_machine_id   = azurerm_linux_virtual_machine.jumpbox.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    }
SETTINGS

}