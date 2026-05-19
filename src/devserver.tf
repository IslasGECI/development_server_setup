resource "azurerm_resource_group" "devserver" {
  name     = "devserver-resources"
  location = "West US 2"
}

resource "azurerm_virtual_network" "devserver" {
  name                = "devserver-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devserver.location
  resource_group_name = azurerm_resource_group.devserver.name
}

resource "azurerm_subnet" "devserver" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.devserver.name
  virtual_network_name = azurerm_virtual_network.devserver.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "devserver" {
  name                = "devserver-public-ip"
  domain_name_label   = "devserver"
  location            = azurerm_resource_group.devserver.location
  resource_group_name = azurerm_resource_group.devserver.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "devserver" {
  name                = "devserver-nic"
  location            = azurerm_resource_group.devserver.location
  resource_group_name = azurerm_resource_group.devserver.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devserver.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devserver.id
  }
}

resource "azurerm_linux_virtual_machine" "devserver" {
  name                = "devserver"
  resource_group_name = azurerm_resource_group.devserver.name
  location            = azurerm_resource_group.devserver.location
  size                = "Standard_B4ms"
  admin_username      = "ciencia_datos"
  network_interface_ids = [
    azurerm_network_interface.devserver.id,
  ]

  admin_ssh_key {
    username   = "ciencia_datos"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-26_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

data "azurerm_public_ip" "devserver" {
  name                = azurerm_public_ip.devserver.name
  resource_group_name = azurerm_linux_virtual_machine.devserver.resource_group_name
}

output "devserver_ip" {
  value = data.azurerm_public_ip.devserver.ip_address
}
