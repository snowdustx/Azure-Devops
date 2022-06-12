provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfrgroup" {
  name     = "RG-Terraform"
  location = "North Europe"
}

data "azurerm_virtual_network" "exist_vnet" {
  name                = "LononVNet"
  resource_group_name = "RecoveryVaultRG"
  
}

data "azurerm_subnet" "exist_subnet" {
  name                 = "Prod_Subnet"
  virtual_network_name = "LononVNet"
  resource_group_name = "RecoveryVaultRG"
 }

resource "azurerm_network_interface" "vm-nic" {
  name                = "vmuk-test-01-nic"
  location            = azurerm_resource_group.tfrgroup.location
  resource_group_name = azurerm_resource_group.tfrgroup.name

  ip_configuration {
    name                          = "internalsub"
    subnet_id                     = data.azurerm_subnet.exist_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "tfvirtual" {
  name                = "vmuk-test-01"
  resource_group_name = azurerm_resource_group.tfrgroup.name
  location            = azurerm_resource_group.tfrgroup.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Password1"
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}