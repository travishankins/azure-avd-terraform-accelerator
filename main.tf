# Azure Virtual Desktop Environment using Modular Architecture
# This configuration creates a complete AVD environment using best-practice modules

# Data sources for current context
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Generate random string for unique naming
resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

# Local values for consistent naming and configuration
locals {
  resource_prefix = var.resource_prefix
  unique_suffix   = random_string.unique.result
  location        = var.location
  
  # Common tags to be applied to all resources
  common_tags = merge(var.tags, {
    Environment   = var.environment
    Project       = "AVD"
    DeployedBy    = "Terraform"
    DeployedDate  = formatdate("YYYY-MM-DD", timestamp())
  })
  
  # Resource names
  resource_group_name            = "${local.resource_prefix}-rg-${local.unique_suffix}"
  vnet_name                      = "${local.resource_prefix}-vnet-${local.unique_suffix}"
  subnet_name                    = "${local.resource_prefix}-subnet-${local.unique_suffix}"
  nsg_name                       = "${local.resource_prefix}-nsg-${local.unique_suffix}"
  storage_account_name           = "${local.resource_prefix}sa${local.unique_suffix}"
  key_vault_name                 = "${local.resource_prefix}-kv-${local.unique_suffix}"
  log_analytics_name             = "${local.resource_prefix}-law-${local.unique_suffix}"
  avd_host_pool_name             = "${local.resource_prefix}-hp-${local.unique_suffix}"
  avd_workspace_name             = "${local.resource_prefix}-ws-${local.unique_suffix}"
  avd_desktop_app_group_name     = "${local.resource_prefix}-dag-${local.unique_suffix}"
  vm_name_prefix                 = "${local.resource_prefix}-vm"
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.common_tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  
  # VNet Configuration
  use_existing_vnet             = var.use_existing_vnet
  existing_vnet_name           = var.existing_vnet_name
  existing_vnet_resource_group = var.existing_vnet_resource_group
  vnet_name                    = local.vnet_name
  vnet_address_space          = var.vnet_address_space
  
  # Subnet Configuration  
  create_new_subnet       = var.create_new_subnet
  existing_subnet_name    = var.existing_subnet_name
  subnet_name            = local.subnet_name
  subnet_address_prefixes = var.subnet_address_prefixes
  
  # NSG Configuration
  nsg_name               = local.nsg_name
  corporate_network_cidr = var.corporate_network_cidr
  
  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  log_analytics_workspace_name  = local.log_analytics_name
  sku                           = var.log_analytics_sku
  retention_in_days             = var.log_analytics_retention_days
  enable_update_management      = var.enable_update_management
  enable_security_center        = var.enable_security_center
  enable_application_insights   = var.enable_application_insights
  application_insights_name     = var.enable_application_insights ? "${local.resource_prefix}-ai-${local.unique_suffix}" : null
  action_group_name             = var.enable_metric_alerts ? "${local.resource_prefix}-ag-${local.unique_suffix}" : null
  notification_emails           = var.notification_emails
  enable_metric_alerts          = var.enable_metric_alerts
  resource_prefix               = local.resource_prefix
  tags                          = local.common_tags
}

# Security Module (Key Vault)
module "security" {
  source = "./modules/security"
  
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  key_vault_name                   = local.key_vault_name
  sku_name                         = var.key_vault_sku_name
  enabled_for_deployment           = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption      = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment  = var.key_vault_enabled_for_template_deployment
  soft_delete_retention_days       = var.key_vault_soft_delete_retention_days
  purge_protection_enabled         = var.key_vault_purge_protection_enabled
  network_acls_default_action      = var.key_vault_network_acls_default_action
  allowed_subnet_ids               = var.key_vault_allowed_subnet_ids
  generate_admin_password          = var.vm_admin_password == null
  admin_password                   = var.vm_admin_password
  admin_password_length            = var.admin_password_length
  # Additional secrets can be added manually after deployment
  tags                             = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  storage_account_name             = local.storage_account_name
  account_tier                     = var.storage_account_tier
  account_replication_type         = var.storage_account_replication_type
  account_kind                     = var.storage_account_kind
  directory_type                   = var.storage_directory_type
  network_rules_default_action     = var.storage_network_rules_default_action
  allowed_subnet_ids               = var.storage_allowed_subnet_ids
  file_share_name                  = var.fslogix_file_share_name
  file_share_quota_gb              = var.fslogix_storage_quota_gb
  file_share_access_tier           = var.fslogix_file_share_access_tier
  enable_private_endpoint          = var.storage_enable_private_endpoint
  private_endpoint_subnet_id       = var.storage_enable_private_endpoint ? module.networking.subnet_id : null
  virtual_network_id               = var.storage_enable_private_endpoint ? module.networking.virtual_network_id : null
  tags                             = local.common_tags
}

# AVD Module
module "avd" {
  source = "./modules/avd"
  
  resource_group_name                        = azurerm_resource_group.main.name
  location                                   = azurerm_resource_group.main.location
  host_pool_name                             = local.avd_host_pool_name
  host_pool_type                             = var.host_pool_type
  load_balancer_type                         = var.host_pool_load_balancer_type
  maximum_sessions_allowed                   = var.host_pool_maximum_sessions_allowed
  start_vm_on_connect                        = var.host_pool_start_vm_on_connect
  validate_environment                       = var.host_pool_validate_environment
  preferred_app_group_type                   = var.host_pool_preferred_app_group_type
  custom_rdp_properties                      = var.custom_rdp_properties
  host_pool_friendly_name                    = "${var.resource_prefix} Host Pool"
  host_pool_description                      = "Host Pool for ${var.resource_prefix} AVD Environment"
  registration_token_rotation_days           = var.registration_token_rotation_days
  
  # Desktop Application Group
  create_desktop_application_group           = var.create_desktop_application_group
  desktop_application_group_name             = local.avd_desktop_app_group_name
  desktop_application_group_friendly_name    = "${var.resource_prefix} Desktop Application Group"
  desktop_application_group_description      = "Desktop Application Group for ${var.resource_prefix} AVD Environment"
  
  # Remote App Application Group
  create_remote_app_application_group        = var.create_remote_app_application_group
  remote_app_application_group_name          = var.create_remote_app_application_group ? "${local.resource_prefix}-rag-${local.unique_suffix}" : null
  remote_app_application_group_friendly_name = var.create_remote_app_application_group ? "${var.resource_prefix} RemoteApp Application Group" : null
  remote_applications                        = var.remote_applications
  
  # Workspace
  workspace_name                             = local.avd_workspace_name
  workspace_friendly_name                    = "${var.resource_prefix} AVD Workspace"
  workspace_description                      = "Azure Virtual Desktop Workspace for ${var.resource_prefix}"
  
  # Scaling Plan
  enable_scaling_plan                        = var.enable_scaling_plan
  scaling_plan_name                          = var.enable_scaling_plan ? "${local.resource_prefix}-sp-${local.unique_suffix}" : null
  scaling_plan_friendly_name                 = var.enable_scaling_plan ? "${var.resource_prefix} Scaling Plan" : null
  scaling_plan_time_zone                     = var.scaling_plan_time_zone
  scaling_plan_schedules                     = var.scaling_plan_schedules
  
  tags = local.common_tags
}

# Compute Module (Session Hosts)
module "compute" {
  source = "./modules/compute"
  
  resource_group_name               = azurerm_resource_group.main.name
  location                          = azurerm_resource_group.main.location
  subnet_id                         = module.networking.subnet_id
  session_host_count                = var.session_host_count
  vm_name_prefix                    = local.vm_name_prefix
  vm_size                           = var.vm_sku_size
  admin_username                    = var.vm_admin_username
  admin_password                    = module.security.admin_password
  availability_zones                = var.availability_zones
  
  # OS Disk Configuration
  os_disk_caching                   = var.os_disk_caching
  os_disk_storage_account_type      = var.os_disk_storage_account_type
  os_disk_size_gb                   = var.os_disk_size_gb
  
  # Source Image
  source_image_reference            = var.source_image_reference
  
  # Network Configuration
  enable_public_ip                  = var.enable_public_ip
  enable_accelerated_networking     = var.enable_accelerated_networking
  enable_ip_forwarding              = var.enable_ip_forwarding
  
  # Data Disk Configuration
  enable_data_disk                  = var.enable_data_disk
  data_disk_size_gb                 = var.data_disk_size_gb
  data_disk_storage_account_type    = var.data_disk_storage_account_type
  data_disk_caching                 = var.data_disk_caching
  
  # Domain/AAD Join
  enable_aad_join                   = var.domain_join_option == "AzureAD"
  enable_domain_join                = var.domain_join_option == "DomainServices"
  domain_name                       = var.domain_name
  domain_ou_path                    = var.domain_ou_path
  domain_join_username              = var.domain_join_username
  domain_join_password              = var.domain_join_password
  
  # AVD Configuration
  host_pool_name                    = module.avd.host_pool_name
  host_pool_registration_token      = module.avd.host_pool_registration_token
  
  # Monitoring
  enable_monitoring_agent           = var.enable_monitoring
  enable_dependency_agent           = var.enable_dependency_agent
  log_analytics_workspace_id        = var.enable_monitoring ? module.monitoring.log_analytics_workspace_workspace_id : null
  log_analytics_workspace_key       = var.enable_monitoring ? module.monitoring.log_analytics_workspace_key : null
  
  # Custom Script
  enable_custom_script              = var.enable_custom_script
  custom_script_file_uris           = var.custom_script_file_uris
  custom_script_command             = var.custom_script_command
  custom_script_protected_settings  = var.custom_script_protected_settings
  
  # Auto-shutdown
  enable_auto_shutdown              = var.enable_auto_shutdown
  auto_shutdown_time                = var.auto_shutdown_time
  auto_shutdown_timezone            = var.auto_shutdown_timezone
  auto_shutdown_notification_enabled = var.auto_shutdown_notification_enabled
  auto_shutdown_notification_email  = var.auto_shutdown_notification_email
  
  tags = local.common_tags
  
  depends_on = [module.avd]
}

# Backup Module (Azure Backup for Session Hosts)
module "backup" {
  source = "./modules/backup"
  
  enable_backup           = var.enable_backup
  recovery_vault_name     = "${local.resource_prefix}-rsv-${local.unique_suffix}"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  
  # Backup schedule
  backup_frequency        = var.backup_frequency
  backup_time             = var.backup_time
  backup_timezone         = var.backup_timezone
  backup_weekdays         = var.backup_weekdays
  
  # Retention policies
  daily_retention_count   = var.backup_daily_retention_count
  weekly_retention_count  = var.backup_weekly_retention_count
  monthly_retention_count = var.backup_monthly_retention_count
  yearly_retention_count  = var.backup_yearly_retention_count
  
  # VMs to protect
  vm_ids = var.enable_backup ? module.compute.session_host_ids : []
  
  tags = local.common_tags
  
  depends_on = [module.compute]
}

# Image Gallery Module (Shared Image Gallery for Golden Images)
module "image_gallery" {
  source = "./modules/image_gallery"
  
  enable_image_gallery       = var.enable_image_gallery
  gallery_name               = replace("${local.resource_prefix}_sig_${local.unique_suffix}", "-", "_")
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  gallery_description        = "AVD Golden Images for ${var.resource_prefix} Environment"
  
  # Image definitions
  create_win11_definition    = var.create_win11_image_definition
  create_win10_definition    = var.create_win10_image_definition
  win11_image_name           = "win11-multisession-avd"
  win10_image_name           = "win10-multisession-avd"
  
  # CI/CD integration
  image_builder_principal_id = var.image_builder_principal_id
  
  tags = local.common_tags
}

# Policy Module (Azure Policy for Governance)
module "policy" {
  source = "./modules/policy"
  
  enable_policies            = var.enable_policies
  resource_group_id          = azurerm_resource_group.main.id
  location                   = azurerm_resource_group.main.location
  
  # Governance policies
  require_environment_tag    = var.policy_require_environment_tag
  allowed_vm_sizes           = var.policy_allowed_vm_sizes
  
  # Security policies
  deploy_antimalware         = var.policy_deploy_antimalware
  audit_disk_encryption      = var.policy_audit_disk_encryption
  
  # Monitoring policies
  enable_vm_diagnostics      = var.policy_enable_vm_diagnostics
  log_analytics_workspace_id = var.policy_enable_vm_diagnostics ? module.monitoring.log_analytics_workspace_id : ""
}

# Diagnostic Settings for AVD Resources
resource "azurerm_monitor_diagnostic_setting" "avd_workspace" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "avd-workspace-diagnostics"
  target_resource_id         = module.avd.workspace_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  enabled_log {
    category = "Checkpoint"
  }
  
  enabled_log {
    category = "Error"
  }
  
  enabled_log {
    category = "Management"
  }
  
  enabled_log {
    category = "Feed"
  }

  enabled_log {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "avd_host_pool" {
  count                      = var.enable_monitoring ? 1 : 0
  name                       = "avd-hostpool-diagnostics"
  target_resource_id         = module.avd.host_pool_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  enabled_log {
    category = "Checkpoint"
  }
  
  enabled_log {
    category = "Error"
  }
  
  enabled_log {
    category = "Management"
  }
  
  enabled_log {
    category = "Connection"
  }
  
  enabled_log {
    category = "HostRegistration"
  }
  
  enabled_log {
    category = "AgentHealthStatus"
  }

  enabled_log {
    category = "AllMetrics"
  }
}

# Update monitoring module with VM resource IDs for alerts
module "monitoring_alerts" {
  source = "./modules/monitoring"
  count  = var.enable_metric_alerts ? 1 : 0
  
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  log_analytics_workspace_name  = "${local.log_analytics_name}-alerts"
  sku                           = var.log_analytics_sku
  retention_in_days             = var.log_analytics_retention_days
  enable_update_management      = false
  enable_security_center        = false
  enable_application_insights   = false
  action_group_name             = "${local.resource_prefix}-ag-${local.unique_suffix}"
  notification_emails           = var.notification_emails
  enable_metric_alerts          = var.enable_metric_alerts
  vm_resource_ids               = module.compute.session_host_ids
  resource_prefix               = local.resource_prefix
  cpu_alert_threshold           = var.cpu_alert_threshold
  memory_alert_threshold_bytes  = var.memory_alert_threshold_bytes
  tags                          = local.common_tags
}