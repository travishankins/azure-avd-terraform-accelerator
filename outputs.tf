# Outputs for Azure Virtual Desktop Environment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = var.location
}

# AVD Resources
output "avd_host_pool_id" {
  description = "ID of the AVD host pool"
  value       = module.avd.host_pool_id
}

output "avd_host_pool_name" {
  description = "Name of the AVD host pool"
  value       = module.avd.host_pool_name
}

output "avd_workspace_id" {
  description = "ID of the AVD workspace"
  value       = module.avd.workspace_id
}

output "avd_workspace_name" {
  description = "Name of the AVD workspace"
  value       = module.avd.workspace_name
}

output "avd_desktop_application_group_id" {
  description = "ID of the desktop application group"
  value       = module.avd.desktop_application_group_id
}

output "avd_desktop_application_group_name" {
  description = "Name of the desktop application group"
  value       = module.avd.desktop_application_group_name
}

output "avd_remote_app_application_group_id" {
  description = "ID of the remote app application group"
  value       = module.avd.remote_app_application_group_id
}

output "avd_remote_app_application_group_name" {
  description = "Name of the remote app application group"
  value       = module.avd.remote_app_application_group_name
}

# Network Resources
output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = module.networking.virtual_network_id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.networking.virtual_network_name
}

output "subnet_id" {
  description = "ID of the AVD subnet"
  value       = module.networking.subnet_id
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = module.networking.network_security_group_id
}

# Session Host Information
output "session_host_names" {
  description = "Names of the session host VMs"
  value       = module.compute.session_host_names
}

output "session_host_ids" {
  description = "IDs of the session host VMs"
  value       = module.compute.session_host_ids
}

output "session_host_private_ips" {
  description = "Private IP addresses of the session host VMs"
  value       = module.compute.session_host_private_ips
}

output "session_host_public_ips" {
  description = "Public IP addresses of the session host VMs (if enabled)"
  value       = module.compute.session_host_public_ips
}

# Storage Resources
output "storage_account_id" {
  description = "ID of the storage account"
  value       = module.storage.storage_account_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.storage.storage_account_name
}

output "fslogix_file_share_url" {
  description = "URL of the FSLogix file share"
  value       = module.storage.file_share_url
}

output "fslogix_file_share_id" {
  description = "ID of the FSLogix file share"
  value       = module.storage.file_share_id
}

# Key Vault
output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.security.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.security.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.key_vault_uri
}

output "admin_password_secret_name" {
  description = "Name of the admin password secret in Key Vault"
  value       = module.security.admin_password_secret_name
}

# Log Analytics
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "log_analytics_workspace_key" {
  description = "Primary key of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_key
  sensitive   = true
}

# Connection Information
output "avd_workspace_url" {
  description = "URL to access the AVD workspace"
  value       = "https://rdweb.wvd.microsoft.com/arm/webclient/index.html"
}

output "remote_desktop_web_client_url" {
  description = "URL for the Remote Desktop web client"
  value       = "https://client.wvd.microsoft.com/arm/webclient/index.html"
}

# Administrative Information
output "vm_admin_username" {
  description = "Admin username for session host VMs"
  value       = var.vm_admin_username
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the deployed AVD environment"
  value = {
    resource_group         = azurerm_resource_group.main.name
    location              = azurerm_resource_group.main.location
    host_pool_name        = module.avd.host_pool_name
    workspace_name        = module.avd.workspace_name
    session_host_count    = var.session_host_count
    vm_size              = var.vm_sku_size
    environment          = var.environment
    deployment_timestamp = timestamp()
    modules_used = {
      networking = "✓"
      security   = "✓"
      storage    = "✓"
      monitoring = "✓"
      avd        = "✓"
      compute    = "✓"
    }
  }
}

# Module Information
output "module_information" {
  description = "Information about the modules used"
  sensitive   = true
  value = {
    networking_module = {
      vnet_name = module.networking.virtual_network_name
      subnet_name = module.networking.subnet_name
      nsg_name = module.networking.network_security_group_name
    }
    security_module = {
      key_vault_name = module.security.key_vault_name
      admin_password_generated = var.vm_admin_password == null
    }
    storage_module = {
      storage_account_name = module.storage.storage_account_name
      file_share_name = module.storage.file_share_name
      private_endpoint_enabled = var.storage_enable_private_endpoint
    }
    monitoring_module = {
      log_analytics_workspace_name = module.monitoring.log_analytics_workspace_name
      application_insights_enabled = var.enable_application_insights
      metric_alerts_enabled = var.enable_metric_alerts
    }
    avd_module = {
      host_pool_name = module.avd.host_pool_name
      workspace_name = module.avd.workspace_name
      desktop_app_group_enabled = var.create_desktop_application_group
      remote_app_group_enabled = var.create_remote_app_application_group
      scaling_plan_enabled = var.enable_scaling_plan
    }
    compute_module = {
      session_host_count = var.session_host_count
      vm_size = var.vm_sku_size
      aad_join_enabled = var.domain_join_option == "AzureAD"
      domain_join_enabled = var.domain_join_option == "DomainServices"
      auto_shutdown_enabled = var.enable_auto_shutdown
    }
  }
}

# Next Steps
output "next_steps" {
  description = "Next steps after deployment"
  value = [
    "1. Assign users to the AVD application groups in Azure AD",
    "2. Configure FSLogix profile containers on session hosts",
    "3. Install and configure applications on session hosts",
    "4. Test user connectivity to the AVD environment",
    "5. Configure conditional access policies if needed",
    "6. Set up backup policies for session hosts (if enabled)",
    "7. Configure monitoring and alerting rules",
    "8. Review and customize scaling plan schedules (if enabled)",
    "9. Configure private endpoints for enhanced security (if needed)",
    "10. Set up custom applications in RemoteApp groups (if enabled)"
  ]
}

# Important Security Notes
output "security_notes" {
  description = "Important security considerations"
  value = [
    "Admin password is stored in Key Vault: ${module.security.admin_password_secret_name}",
    "Update NSG rules to restrict access from corporate networks only",
    "Enable MFA for all AVD users",
    "Regularly review and update session host images",
    "Monitor logs in Log Analytics workspace: ${module.monitoring.log_analytics_workspace_name}",
    "Consider implementing Conditional Access policies",
    "Review Key Vault access policies and network restrictions",
    "Enable private endpoints for storage and Key Vault in production",
    "Implement proper RBAC for all AVD resources",
    "Regularly review and audit access to AVD environment"
  ]
}

