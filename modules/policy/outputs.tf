output "managed_disk_policy_id" {
  description = "ID of the managed disk policy assignment"
  value       = var.enable_policies ? azurerm_resource_group_policy_assignment.require_managed_disks[0].id : null
}

output "vm_size_policy_id" {
  description = "ID of the VM size restriction policy assignment"
  value       = var.enable_policies && length(var.allowed_vm_sizes) > 0 ? azurerm_resource_group_policy_assignment.allowed_vm_sizes[0].id : null
}

output "environment_tag_policy_id" {
  description = "ID of the environment tag policy assignment"
  value       = var.enable_policies && var.require_environment_tag ? azurerm_resource_group_policy_assignment.require_environment_tag[0].id : null
}

output "antimalware_policy_id" {
  description = "ID of the antimalware policy assignment"
  value       = var.enable_policies && var.deploy_antimalware ? azurerm_resource_group_policy_assignment.deploy_antimalware[0].id : null
}

output "encryption_audit_policy_id" {
  description = "ID of the encryption audit policy assignment"
  value       = var.enable_policies && var.audit_disk_encryption ? azurerm_resource_group_policy_assignment.audit_vm_encryption[0].id : null
}

output "diagnostics_policy_id" {
  description = "ID of the diagnostics policy assignment"
  value       = var.enable_policies && var.enable_vm_diagnostics && var.log_analytics_workspace_id != "" ? azurerm_resource_group_policy_assignment.vm_diagnostic_settings[0].id : null
}
