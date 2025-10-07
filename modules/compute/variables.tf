# Variables for the Compute Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for session hosts"
  type        = string
}

# VM Configuration
variable "session_host_count" {
  description = "Number of session hosts to deploy"
  type        = number
  default     = 2
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "avd-vm"
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
}

variable "availability_zones" {
  description = "Availability zones for VMs"
  type        = list(string)
  default     = []
}

# OS Disk Configuration
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

variable "os_disk_size_gb" {
  description = "Size of OS disk in GB"
  type        = number
  default     = 128
}

# Source Image
variable "source_image_reference" {
  description = "Source image reference"
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

# Network Configuration
variable "private_ip_allocation" {
  description = "Private IP allocation method"
  type        = string
  default     = "Dynamic"
}

variable "enable_public_ip" {
  description = "Enable public IP for VMs"
  type        = bool
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking"
  type        = bool
  default     = true
}

variable "enable_ip_forwarding" {
  description = "Enable IP forwarding"
  type        = bool
  default     = false
}

# Data Disk Configuration
variable "enable_data_disk" {
  description = "Enable data disk for VMs"
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

# Domain/AAD Join Configuration
variable "enable_aad_join" {
  description = "Enable Azure AD join"
  type        = bool
  default     = true
}

variable "enable_domain_join" {
  description = "Enable domain join"
  type        = bool
  default     = false
}

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

# AVD Configuration
variable "host_pool_name" {
  description = "Name of the host pool"
  type        = string
}

variable "host_pool_registration_token" {
  description = "Registration token for the host pool"
  type        = string
  sensitive   = true
}

variable "avd_agent_package_url" {
  description = "URL for AVD agent package"
  type        = string
  default     = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip"
}

# Monitoring Configuration
variable "enable_monitoring_agent" {
  description = "Enable monitoring agent"
  type        = bool
  default     = true
}

variable "enable_dependency_agent" {
  description = "Enable dependency agent"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "log_analytics_workspace_key" {
  description = "Log Analytics workspace key"
  type        = string
  default     = null
  sensitive   = true
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

# Boot Diagnostics
variable "boot_diagnostics_storage_uri" {
  description = "Storage URI for boot diagnostics"
  type        = string
  default     = null
}

# Custom Data
variable "custom_data" {
  description = "Custom data for VM initialization"
  type        = string
  default     = null
}

# Auto-shutdown Configuration
variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time"
  type        = string
  default     = "19:00"
}

variable "auto_shutdown_timezone" {
  description = "Auto-shutdown timezone"
  type        = string
  default     = "Eastern Standard Time"
}

variable "auto_shutdown_notification_enabled" {
  description = "Enable auto-shutdown notifications"
  type        = bool
  default     = false
}

variable "auto_shutdown_notification_time_minutes" {
  description = "Auto-shutdown notification time in minutes"
  type        = number
  default     = 30
}

variable "auto_shutdown_notification_email" {
  description = "Email for auto-shutdown notifications"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}