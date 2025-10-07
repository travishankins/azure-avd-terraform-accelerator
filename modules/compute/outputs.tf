# Outputs for the Compute Module

output "session_host_names" {
  description = "Names of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].name
}

output "session_host_ids" {
  description = "IDs of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].id
}

output "session_host_private_ips" {
  description = "Private IP addresses of the session host VMs"
  value       = azurerm_windows_virtual_machine.session_host[*].private_ip_address
}

output "session_host_public_ips" {
  description = "Public IP addresses of the session host VMs"
  value       = var.enable_public_ip ? azurerm_public_ip.session_host[*].ip_address : []
}

output "network_interface_ids" {
  description = "IDs of the network interfaces"
  value       = azurerm_network_interface.session_host[*].id
}

output "managed_identity_principal_ids" {
  description = "Principal IDs of the managed identities"
  value       = azurerm_windows_virtual_machine.session_host[*].identity[0].principal_id
}

output "data_disk_ids" {
  description = "IDs of the data disks"
  value       = var.enable_data_disk ? azurerm_managed_disk.data_disk[*].id : []
}