# Outputs for the Networking Module

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = var.use_existing_vnet ? data.azurerm_virtual_network.existing[0].id : azurerm_virtual_network.main[0].id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = var.use_existing_vnet ? data.azurerm_virtual_network.existing[0].name : azurerm_virtual_network.main[0].name
}

output "virtual_network_address_space" {
  description = "Address space of the virtual network"
  value       = var.use_existing_vnet ? data.azurerm_virtual_network.existing[0].address_space : azurerm_virtual_network.main[0].address_space
}

output "subnet_id" {
  description = "ID of the AVD subnet"
  value       = var.create_new_subnet ? azurerm_subnet.avd_subnet[0].id : data.azurerm_subnet.existing[0].id
}

output "subnet_name" {
  description = "Name of the AVD subnet"
  value       = var.create_new_subnet ? azurerm_subnet.avd_subnet[0].name : data.azurerm_subnet.existing[0].name
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the AVD subnet"
  value       = var.create_new_subnet ? azurerm_subnet.avd_subnet[0].address_prefixes : data.azurerm_subnet.existing[0].address_prefixes
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.avd_nsg.id
}

output "network_security_group_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.avd_nsg.name
}

# Configuration information
output "configuration_summary" {
  description = "Summary of networking configuration"
  value = {
    using_existing_vnet = var.use_existing_vnet
    using_existing_subnet = !var.create_new_subnet
    vnet_name = var.use_existing_vnet ? var.existing_vnet_name : var.vnet_name
    subnet_name = var.create_new_subnet ? var.subnet_name : var.existing_subnet_name
  }
}