terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "testgroup" {
  name     = var.resource_group
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "testnetwork" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.testgroup.name
  location            = var.location
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "testsubnet" {
  name                 = "${var.virtual_network_name}-sub1"
  resource_group_name  = azurerm_resource_group.testgroup.name
  virtual_network_name = azurerm_virtual_network.testnetwork.name
  address_prefixes     = [var.subnet_prefix]
}

resource "azurerm_public_ip" "testpubip" {
    name                         = "${var.vm_name}-testpubip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.testgroup.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "testnic" {
  name                = "${var.vm_name}-testnic"
  location            = var.location
  resource_group_name = azurerm_resource_group.testgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.vm_private_ip
    public_ip_address_id = azurerm_public_ip.testpubip.id
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.testgroup.name
  location            = var.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.testnic.id]
#   delete_data_disks_on_termination = true
#   delete_os_disk_on_termination = true
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "8_2"
        version   = "latest"
    } 
}