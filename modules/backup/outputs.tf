output "recovery_vault_id" {
  description = "ID of the Recovery Services Vault"
  value       = var.enable_backup ? azurerm_recovery_services_vault.main[0].id : null
}

output "recovery_vault_name" {
  description = "Name of the Recovery Services Vault"
  value       = var.enable_backup ? azurerm_recovery_services_vault.main[0].name : null
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = var.enable_backup ? azurerm_backup_policy_vm.main[0].id : null
}

output "protected_vm_ids" {
  description = "IDs of VMs protected by backup"
  value       = var.enable_backup ? [for vm in azurerm_backup_protected_vm.main : vm.id] : []
}
