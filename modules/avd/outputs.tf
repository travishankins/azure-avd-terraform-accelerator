# Outputs for the AVD Module

output "host_pool_id" {
  description = "ID of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.id
}

output "host_pool_name" {
  description = "Name of the AVD host pool"
  value       = azurerm_virtual_desktop_host_pool.main.name
}

output "host_pool_registration_token" {
  description = "Registration token for the host pool"
  value       = azurerm_virtual_desktop_host_pool_registration_info.main.token
  sensitive   = true
}

output "workspace_id" {
  description = "ID of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.id
}

output "workspace_name" {
  description = "Name of the AVD workspace"
  value       = azurerm_virtual_desktop_workspace.main.name
}

output "desktop_application_group_id" {
  description = "ID of the desktop application group"
  value       = var.create_desktop_application_group ? azurerm_virtual_desktop_application_group.desktop[0].id : null
}

output "desktop_application_group_name" {
  description = "Name of the desktop application group"
  value       = var.create_desktop_application_group ? azurerm_virtual_desktop_application_group.desktop[0].name : null
}

output "remote_app_application_group_id" {
  description = "ID of the remote app application group"
  value       = var.create_remote_app_application_group ? azurerm_virtual_desktop_application_group.remote_app[0].id : null
}

output "remote_app_application_group_name" {
  description = "Name of the remote app application group"
  value       = var.create_remote_app_application_group ? azurerm_virtual_desktop_application_group.remote_app[0].name : null
}

output "scaling_plan_id" {
  description = "ID of the scaling plan"
  value       = var.enable_scaling_plan ? azurerm_virtual_desktop_scaling_plan.main[0].id : null
}

output "remote_applications" {
  description = "Map of remote applications"
  value       = azurerm_virtual_desktop_application.apps
}