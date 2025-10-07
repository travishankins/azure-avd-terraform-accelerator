# ==============================================================================
# BACKUP CONFIGURATION (Azure Backup for Session Hosts)
# ==============================================================================

variable "enable_backup" {
  description = "Enable Azure Backup for session hosts"
  type        = bool
  default     = false
}

variable "backup_frequency" {
  description = "Backup frequency (Daily or Weekly)"
  type        = string
  default     = "Daily"
  validation {
    condition     = contains(["Daily", "Weekly"], var.backup_frequency)
    error_message = "Backup frequency must be Daily or Weekly."
  }
}

variable "backup_time" {
  description = "Time of day for backup in 24-hour format (e.g., 02:00)"
  type        = string
  default     = "02:00"
}

variable "backup_timezone" {
  description = "Timezone for backup schedule"
  type        = string
  default     = "UTC"
}

variable "backup_weekdays" {
  description = "Days of week for backup (only used if backup_frequency is Weekly)"
  type        = list(string)
  default     = ["Sunday"]
}

variable "backup_daily_retention_count" {
  description = "Number of daily backups to retain (7-9999 days)"
  type        = number
  default     = 30
}

variable "backup_weekly_retention_count" {
  description = "Number of weekly backups to retain (0 to disable)"
  type        = number
  default     = 12
}

variable "backup_monthly_retention_count" {
  description = "Number of monthly backups to retain (0 to disable)"
  type        = number
  default     = 12
}

variable "backup_yearly_retention_count" {
  description = "Number of yearly backups to retain (0 to disable)"
  type        = number
  default     = 5
}

# ==============================================================================
# IMAGE GALLERY CONFIGURATION (Shared Image Gallery for Golden Images)
# ==============================================================================

variable "enable_image_gallery" {
  description = "Enable Shared Image Gallery for golden images"
  type        = bool
  default     = false
}

variable "create_win11_image_definition" {
  description = "Create Windows 11 Multi-Session image definition in gallery"
  type        = bool
  default     = true
}

variable "create_win10_image_definition" {
  description = "Create Windows 10 Multi-Session image definition in gallery"
  type        = bool
  default     = false
}

variable "image_builder_principal_id" {
  description = "Object ID of service principal for image building (CI/CD pipeline). Leave empty if not using automated image building"
  type        = string
  default     = ""
}

# ==============================================================================
# POLICY CONFIGURATION (Azure Policy for Governance)
# ==============================================================================

variable "enable_policies" {
  description = "Enable Azure Policy assignments for governance and compliance"
  type        = bool
  default     = false
}

variable "policy_require_environment_tag" {
  description = "Require Environment tag on all resources via Azure Policy"
  type        = bool
  default     = true
}

variable "policy_allowed_vm_sizes" {
  description = "List of allowed VM sizes for session hosts (enforced via Azure Policy)"
  type        = list(string)
  default = [
    "Standard_D2s_v5",
    "Standard_D4s_v5",
    "Standard_D8s_v5",
    "Standard_D16s_v5",
    "Standard_D2ds_v5",
    "Standard_D4ds_v5",
    "Standard_D8ds_v5",
    "Standard_D16ds_v5"
  ]
}

variable "policy_deploy_antimalware" {
  description = "Deploy Microsoft Antimalware extension to all VMs via Azure Policy"
  type        = bool
  default     = true
}

variable "policy_audit_disk_encryption" {
  description = "Audit VMs without disk encryption enabled via Azure Policy"
  type        = bool
  default     = true
}

variable "policy_enable_vm_diagnostics" {
  description = "Enable diagnostic settings for VMs via Azure Policy"
  type        = bool
  default     = true
}
