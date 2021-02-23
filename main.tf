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
  name     = "test-resources"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "testnetwork" {
  name                = "test-network"
  resource_group_name = azurerm_resource_group.testgroup.name
  location            = azurerm_resource_group.testgroup.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "testsubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.testgroup.name
  virtual_network_name = azurerm_virtual_network.testnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "testpubip" {
    name                         = "testpubip"
    location                     = azurerm_resource_group.testgroup.location
    resource_group_name          = azurerm_resource_group.testgroup.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "testnic" {
  name                = "test-nic"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.2.10"
    public_ip_address_id = azurerm_public_ip.testpubip.id
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "test-machine"
  resource_group_name = azurerm_resource_group.testgroup.name
  location            = azurerm_resource_group.testgroup.location
  size                = "Standard_A1_V2"
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