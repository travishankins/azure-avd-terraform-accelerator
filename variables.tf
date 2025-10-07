# Variables for Azure Virtual Desktop Environment

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network (used when creating new VNet)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AVD subnet (used when creating new subnet)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "corporate_network_cidr" {
  description = "CIDR block for your corporate network (used in NSG rules)"
  type        = string
  default     = "0.0.0.0/0"
}

# Existing Network Configuration
variable "use_existing_vnet" {
  description = "Whether to use an existing VNet instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_vnet_name" {
  description = "Name of existing VNet (required if use_existing_vnet is true)"
  type        = string
  default     = ""
}

variable "existing_vnet_resource_group" {
  description = "Resource group of existing VNet (required if use_existing_vnet is true)"
  type        = string
  default     = ""
}

variable "create_new_subnet" {
  description = "Whether to create a new subnet (true) or use existing subnet (false)"
  type        = bool
  default     = true
}

variable "existing_subnet_name" {
  description = "Name of existing subnet (required if create_new_subnet is false)"
  type        = string
  default     = ""
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "avd"
  
  validation {
    condition     = length(var.resource_prefix) <= 10 && can(regex("^[a-zA-Z0-9]+$", var.resource_prefix))
    error_message = "Resource prefix must be alphanumeric and no more than 10 characters."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
  
  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3", "Central US",
      "North Central US", "South Central US", "West Central US", "Canada Central",
      "Canada East", "Brazil South", "UK South", "UK West", "West Europe",
      "North Europe", "France Central", "Germany West Central", "Switzerland North",
      "Norway East", "Sweden Central", "Australia East", "Australia Southeast",
      "East Asia", "Southeast Asia", "Japan East", "Japan West", "Korea Central",
      "South Africa North", "UAE North", "Central India", "South India", "West India"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, test, staging, or prod."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Owner       = "IT Department"
    CostCenter  = "12345"
    Application = "Azure Virtual Desktop"
  }
}

# AVD Host Pool Configuration
variable "host_pool_type" {
  description = "Type of host pool (Personal or Pooled)"
  type        = string
  default     = "Pooled"
  
  validation {
    condition     = contains(["Personal", "Pooled"], var.host_pool_type)
    error_message = "Host pool type must be either Personal or Pooled."
  }
}

variable "host_pool_load_balancer_type" {
  description = "Load balancer type for the host pool"
  type        = string
  default     = "BreadthFirst"
  
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.host_pool_load_balancer_type)
    error_message = "Load balancer type must be BreadthFirst, DepthFirst, or Persistent."
  }
}

variable "host_pool_maximum_sessions_allowed" {
  description = "Maximum number of sessions allowed per session host"
  type        = number
  default     = 10
  
  validation {
    condition     = var.host_pool_maximum_sessions_allowed > 0 && var.host_pool_maximum_sessions_allowed <= 50
    error_message = "Maximum sessions allowed must be between 1 and 50."
  }
}

variable "host_pool_start_vm_on_connect" {
  description = "Enable Start VM on Connect feature"
  type        = bool
  default     = true
}

variable "host_pool_validate_environment" {
  description = "Enable validation environment for the host pool"
  type        = bool
  default     = false
}

# Session Host Configuration
variable "session_host_count" {
  description = "Number of session hosts to deploy"
  type        = number
  default     = 2
  
  validation {
    condition     = var.session_host_count > 0 && var.session_host_count <= 100
    error_message = "Session host count must be between 1 and 100."
  }
}

variable "vm_sku_size" {
  description = "SKU size for session host VMs"
  type        = string
  default     = "Standard_D4s_v5"
  
  validation {
    condition = contains([
      "Standard_D2s_v5", "Standard_D4s_v5", "Standard_D8s_v5", "Standard_D16s_v5",
      "Standard_D2s_v4", "Standard_D4s_v4", "Standard_D8s_v4", "Standard_D16s_v4",
      "Standard_E2s_v5", "Standard_E4s_v5", "Standard_E8s_v5", "Standard_E16s_v5",
      "Standard_F2s_v2", "Standard_F4s_v2", "Standard_F8s_v2", "Standard_F16s_v2"
    ], var.vm_sku_size)
    error_message = "VM SKU size must be a valid Azure VM size suitable for AVD."
  }
}

variable "vm_admin_username" {
  description = "Admin username for session host VMs"
  type        = string
  default     = "avdadmin"
  
  validation {
    condition     = length(var.vm_admin_username) >= 3 && length(var.vm_admin_username) <= 20
    error_message = "VM admin username must be between 3 and 20 characters."
  }
}

variable "vm_admin_password" {
  description = "Admin password for session host VMs (if not provided, will be auto-generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB for session host VMs"
  type        = number
  default     = 128
  
  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 4095
    error_message = "OS disk size must be between 30 and 4095 GB."
  }
}

variable "availability_zones" {
  description = "Availability zones for session host VMs"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Auto-shutdown Configuration
variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown"
  type        = string
  default     = "Eastern Standard Time"
}

variable "auto_shutdown_time" {
  description = "Time for auto-shutdown (24-hour format without colon, e.g., '1900' for 7 PM)"
  type        = string
  default     = "1900"
  
  validation {
    condition     = can(regex("^([0-1][0-9]|2[0-3])[0-5][0-9]$", var.auto_shutdown_time))
    error_message = "Auto-shutdown time must be in HHmm format (24-hour, e.g., '1900' for 7 PM)."
  }
}

# Storage Configuration
variable "fslogix_storage_quota_gb" {
  description = "Storage quota in GB for FSLogix file share"
  type        = number
  default     = 1024
  
  validation {
    condition     = var.fslogix_storage_quota_gb >= 100 && var.fslogix_storage_quota_gb <= 102400
    error_message = "FSLogix storage quota must be between 100 and 102400 GB."
  }
}

# Log Analytics Configuration
variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be Free, Standalone, PerNode, or PerGB2018."
  }
}

variable "log_analytics_retention_days" {
  description = "Retention period in days for Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

# Advanced Configuration
variable "enable_accelerated_networking" {
  description = "Enable accelerated networking for session host NICs"
  type        = bool
  default     = true
}

variable "enable_ip_forwarding" {
  description = "Enable IP forwarding for session host NICs"
  type        = bool
  default     = false
}

variable "domain_join_option" {
  description = "Domain join option (AzureAD or DomainServices)"
  type        = string
  default     = "AzureAD"
  
  validation {
    condition     = contains(["AzureAD", "DomainServices"], var.domain_join_option)
    error_message = "Domain join option must be AzureAD or DomainServices."
  }
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for AVD"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable Azure Backup for session hosts"
  type        = bool
  default     = false
}

variable "custom_rdp_properties" {
  description = "Custom RDP properties for the host pool"
  type        = string
  default     = "audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:*;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2"
}

# Monitoring and Alerting Configuration
variable "enable_update_management" {
  description = "Enable Update Management solution"
  type        = bool
  default     = true
}

variable "enable_security_center" {
  description = "Enable Security Center solution"
  type        = bool
  default     = true
}

variable "enable_application_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = false
}

variable "enable_metric_alerts" {
  description = "Enable metric alerts"
  type        = bool
  default     = true
}

variable "notification_emails" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
}

variable "cpu_alert_threshold" {
  description = "CPU usage threshold for alerts (percentage)"
  type        = number
  default     = 80
}

variable "memory_alert_threshold_bytes" {
  description = "Memory threshold for alerts (bytes)"
  type        = number
  default     = 1073741824 # 1GB
}

# Key Vault Configuration
variable "key_vault_sku_name" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "standard"
}

variable "key_vault_enabled_for_deployment" {
  description = "Enable Key Vault for deployment"
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "Enable Key Vault for template deployment"
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
  default     = 7
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_network_acls_default_action" {
  description = "Default action for Key Vault network ACLs"
  type        = string
  default     = "Allow"
}

variable "key_vault_allowed_subnet_ids" {
  description = "List of allowed subnet IDs for Key Vault"
  type        = list(string)
  default     = []
}

variable "admin_password_length" {
  description = "Length of the generated admin password"
  type        = number
  default     = 16
}

# Note: Additional Key Vault secrets should be managed separately
# to avoid Terraform for_each issues with sensitive values

# Storage Configuration
variable "storage_account_tier" {
  description = "Tier of the storage account"
  type        = string
  default     = "Premium"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
}

variable "storage_account_kind" {
  description = "Kind of storage account"
  type        = string
  default     = "FileStorage"
}

variable "storage_directory_type" {
  description = "Directory type for Azure Files authentication"
  type        = string
  default     = "AADKERB"
}

variable "storage_network_rules_default_action" {
  description = "Default action for storage network rules"
  type        = string
  default     = "Allow"
}

variable "storage_allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the storage account"
  type        = list(string)
  default     = []
}

variable "fslogix_file_share_name" {
  description = "Name of the FSLogix file share"
  type        = string
  default     = "fslogix"
}

variable "fslogix_file_share_access_tier" {
  description = "Access tier for the FSLogix file share"
  type        = string
  default     = "Premium"
}

variable "storage_enable_private_endpoint" {
  description = "Enable private endpoint for storage account"
  type        = bool
  default     = false
}

# Host Pool Advanced Configuration
variable "host_pool_preferred_app_group_type" {
  description = "Preferred application group type"
  type        = string
  default     = "Desktop"
}

variable "registration_token_rotation_days" {
  description = "Number of days for registration token rotation"
  type        = number
  default     = 30
}

# Application Group Configuration
variable "create_desktop_application_group" {
  description = "Create desktop application group"
  type        = bool
  default     = true
}

variable "create_remote_app_application_group" {
  description = "Create remote app application group"
  type        = bool
  default     = false
}

variable "remote_applications" {
  description = "Remote applications to publish"
  type = map(object({
    friendly_name                = string
    description                  = string
    path                        = string
    command_line_argument_policy = string
    command_line_arguments      = string
    show_in_portal              = bool
    icon_path                   = string
    icon_index                  = number
  }))
  default = {}
}

# Scaling Plan Configuration
variable "enable_scaling_plan" {
  description = "Enable scaling plan for the host pool"
  type        = bool
  default     = false
}

variable "scaling_plan_time_zone" {
  description = "Time zone for the scaling plan"
  type        = string
  default     = "Eastern Standard Time"
}

variable "scaling_plan_schedules" {
  description = "Schedules for the scaling plan"
  type = list(object({
    name                                 = string
    days_of_week                        = list(string)
    ramp_up_start_time                  = string
    ramp_up_load_balancing_algorithm    = string
    ramp_up_minimum_hosts_percent       = number
    ramp_up_capacity_threshold_percent  = number
    peak_start_time                     = string
    peak_load_balancing_algorithm       = string
    ramp_down_start_time                = string
    ramp_down_load_balancing_algorithm  = string
    ramp_down_minimum_hosts_percent     = number
    ramp_down_capacity_threshold_percent = number
    ramp_down_force_logoff_users        = bool
    ramp_down_stop_hosts_when           = string
    ramp_down_wait_time_minutes         = number
    ramp_down_notification_message      = string
    off_peak_start_time                 = string
    off_peak_load_balancing_algorithm   = string
  }))
  default = []
}

# VM Advanced Configuration
variable "source_image_reference" {
  description = "Source image reference for session hosts"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }
}

variable "enable_public_ip" {
  description = "Enable public IP for session hosts"
  type        = bool
  default     = false
}

variable "os_disk_caching" {
  description = "Caching type for OS disk"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disk"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_data_disk" {
  description = "Enable data disk for session hosts"
  type        = bool
  default     = false
}

variable "data_disk_size_gb" {
  description = "Size of data disk in GB"
  type        = number
  default     = 256
}

variable "data_disk_storage_account_type" {
  description = "Storage account type for data disk"
  type        = string
  default     = "Premium_LRS"
}

variable "data_disk_caching" {
  description = "Caching type for data disk"
  type        = string
  default     = "ReadWrite"
}

# Domain Join Configuration
variable "domain_name" {
  description = "Domain name for domain join"
  type        = string
  default     = null
}

variable "domain_ou_path" {
  description = "OU path for domain join"
  type        = string
  default     = null
}

variable "domain_join_username" {
  description = "Username for domain join"
  type        = string
  default     = null
}

variable "domain_join_password" {
  description = "Password for domain join"
  type        = string
  default     = null
  sensitive   = true
}

# Monitoring Agents
variable "enable_dependency_agent" {
  description = "Enable dependency agent"
  type        = bool
  default     = false
}

# Custom Script Extension
variable "enable_custom_script" {
  description = "Enable custom script extension"
  type        = bool
  default     = false
}

variable "custom_script_file_uris" {
  description = "File URIs for custom script"
  type        = list(string)
  default     = []
}

variable "custom_script_command" {
  description = "Command to execute for custom script"
  type        = string
  default     = null
}

variable "custom_script_protected_settings" {
  description = "Protected settings for custom script"
  type        = map(string)
  default     = null
  sensitive   = true
}

# Auto-shutdown Configuration
variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for session hosts"
  type        = bool
  default     = true
}

variable "auto_shutdown_notification_enabled" {
  description = "Enable auto-shutdown notifications"
  type        = bool
  default     = false
}

variable "auto_shutdown_notification_email" {
  description = "Email for auto-shutdown notifications"
  type        = string
  default     = null
}