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
