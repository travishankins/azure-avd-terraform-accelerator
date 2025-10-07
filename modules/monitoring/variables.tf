# Variables for the Monitoring Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.sku)
    error_message = "Log Analytics SKU must be Free, Standalone, PerNode, or PerGB2018."
  }
}

variable "retention_in_days" {
  description = "Retention period in days for Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily quota in GB for Log Analytics workspace"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion for Log Analytics workspace"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query for Log Analytics workspace"
  type        = bool
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Reservation capacity in GB per day"
  type        = number
  default     = null
}

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

variable "application_insights_name" {
  description = "Name of the Application Insights resource"
  type        = string
  default     = null
}

variable "action_group_name" {
  description = "Name of the action group"
  type        = string
  default     = null
}

variable "action_group_short_name" {
  description = "Short name of the action group"
  type        = string
  default     = "avdalert"
}

variable "notification_emails" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
}

variable "enable_metric_alerts" {
  description = "Enable metric alerts"
  type        = bool
  default     = true
}

variable "vm_resource_ids" {
  description = "List of VM resource IDs for metric alerts"
  type        = list(string)
  default     = []
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "avd"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}