# Outputs for the Security Module

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "admin_password_secret_name" {
  description = "Name of the admin password secret"
  value       = azurerm_key_vault_secret.vm_admin_password.name
}

output "admin_password_secret_id" {
  description = "ID of the admin password secret"
  value       = azurerm_key_vault_secret.vm_admin_password.id
}

output "admin_password" {
  description = "Generated admin password (if generated)"
  value       = var.generate_admin_password ? random_password.vm_admin[0].result : var.admin_password
  sensitive   = true
}

output "private_endpoint_ip" {
  description = "Private IP address of the Key Vault private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.key_vault[0].private_service_connection[0].private_ip_address : null
}