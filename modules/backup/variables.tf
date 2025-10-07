variable "enable_backup" {
  description = "Enable Azure Backup for session hosts"
  type        = bool
  default     = false
}

variable "recovery_vault_name" {
  description = "Name of the Recovery Services Vault"
  type        = string
  default     = "rsv-avd"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "recovery_vault_sku" {
  description = "SKU for Recovery Services Vault"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "RS0"], var.recovery_vault_sku)
    error_message = "Recovery vault SKU must be Standard or RS0."
  }
}

variable "soft_delete_enabled" {
  description = "Enable soft delete for backup vault"
  type        = bool
  default     = true
}

variable "backup_policy_name" {
  description = "Name of the backup policy"
  type        = string
  default     = "avd-backup-policy"
}

variable "backup_timezone" {
  description = "Timezone for backup schedule"
  type        = string
  default     = "UTC"
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
  description = "Time of day for backup (24-hour format, e.g., 02:00)"
  type        = string
  default     = "02:00"
}

variable "backup_weekdays" {
  description = "Days of week for backup (only for Weekly frequency)"
  type        = list(string)
  default     = ["Sunday"]
  validation {
    condition = alltrue([
      for day in var.backup_weekdays : contains(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], day)
    ])
    error_message = "Backup weekdays must be valid day names."
  }
}

variable "daily_retention_count" {
  description = "Number of daily backups to retain"
  type        = number
  default     = 30
  validation {
    condition     = var.daily_retention_count >= 7 && var.daily_retention_count <= 9999
    error_message = "Daily retention must be between 7 and 9999 days."
  }
}

variable "weekly_retention_count" {
  description = "Number of weekly backups to retain (0 to disable)"
  type        = number
  default     = 12
  validation {
    condition     = var.weekly_retention_count >= 0 && var.weekly_retention_count <= 5163
    error_message = "Weekly retention must be between 0 and 5163 weeks."
  }
}

variable "monthly_retention_count" {
  description = "Number of monthly backups to retain (0 to disable)"
  type        = number
  default     = 12
  validation {
    condition     = var.monthly_retention_count >= 0 && var.monthly_retention_count <= 1188
    error_message = "Monthly retention must be between 0 and 1188 months."
  }
}

variable "yearly_retention_count" {
  description = "Number of yearly backups to retain (0 to disable)"
  type        = number
  default     = 5
  validation {
    condition     = var.yearly_retention_count >= 0 && var.yearly_retention_count <= 99
    error_message = "Yearly retention must be between 0 and 99 years."
  }
}

variable "backup_retention_weekdays" {
  description = "Weekdays to retain for weekly/monthly/yearly backups"
  type        = list(string)
  default     = ["Sunday"]
  validation {
    condition = alltrue([
      for day in var.backup_retention_weekdays : contains(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], day)
    ])
    error_message = "Retention weekdays must be valid day names."
  }
}

variable "vm_ids" {
  description = "List of VM resource IDs to protect with backup"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
