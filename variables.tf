variable "resource_group" {
  description = "The name of the resource group in which to create the resources."
  default = "testgroup"
}

variable "location" {
  description = "The location/region where the resources are created."
  default     = "westeurope"
}

variable "address_space" {
  description = "The virtual network ( address range )."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The subnet address prefix ( address range )."
  default     = "10.0.2.0/24"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "testnetwork"
}

# Test VM Variables
variable "vm_name" {
  description = "Specifies VM name"
  default = "test_vm"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_A1_v2"
}

variable "vm_private_ip" {
  description = "Specifies the private ip of the virtual machine."
  default     = "10.0.2.10"
}