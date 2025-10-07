# Variables for the Security Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  description = "Enable Key Vault for deployment"
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = true
}

variable "enabled_for_template_deployment" {
  description = "Enable Key Vault for template deployment"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "network_acls_default_action" {
  description = "Default action for network ACLs"
  type        = string
  default     = "Allow"
}

variable "network_acls_bypass" {
  description = "Bypass for network ACLs"
  type        = string
  default     = "AzureServices"
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs"
  type        = list(string)
  default     = []
}

variable "admin_secret_permissions" {
  description = "Secret permissions for admin"
  type        = list(string)
  default     = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

variable "admin_key_permissions" {
  description = "Key permissions for admin"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Recover", "Backup", "Restore", "Purge"]
}

variable "admin_certificate_permissions" {
  description = "Certificate permissions for admin"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Recover", "Backup", "Restore", "Purge"]
}

variable "additional_access_policies" {
  description = "Additional access policies for the Key Vault"
  type = map(object({
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
  }))
  default = {}
}

variable "generate_admin_password" {
  description = "Generate admin password automatically"
  type        = bool
  default     = true
}

variable "admin_password" {
  description = "Admin password (if not generated)"
  type        = string
  default     = null
  sensitive   = true
}

variable "admin_password_length" {
  description = "Length of the generated admin password"
  type        = number
  default     = 16
}

variable "admin_password_special_chars" {
  description = "Include special characters in generated password"
  type        = bool
  default     = true
}

variable "admin_password_upper_chars" {
  description = "Include upper case characters in generated password"
  type        = bool
  default     = true
}

variable "admin_password_lower_chars" {
  description = "Include lower case characters in generated password"
  type        = bool
  default     = true
}

variable "admin_password_numeric_chars" {
  description = "Include numeric characters in generated password"
  type        = bool
  default     = true
}

variable "admin_password_secret_name" {
  description = "Name of the secret for admin password"
  type        = string
  default     = "vm-admin-password"
}

# Note: Additional secrets should be managed separately to avoid
# sensitive value issues with for_each in Terraform

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "Virtual network ID for private DNS zone link"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}