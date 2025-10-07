# Outputs for the Storage Module

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_endpoint" {
  description = "Primary endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "file_share_id" {
  description = "ID of the FSLogix file share"
  value       = azurerm_storage_share.fslogix.id
}

output "file_share_name" {
  description = "Name of the FSLogix file share"
  value       = azurerm_storage_share.fslogix.name
}

output "file_share_url" {
  description = "URL of the FSLogix file share"
  value       = "\\\\${azurerm_storage_account.main.name}.file.core.windows.net\\${azurerm_storage_share.fslogix.name}"
}

output "private_endpoint_ip" {
  description = "Private IP address of the storage account private endpoint"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage[0].private_service_connection[0].private_ip_address : null
}