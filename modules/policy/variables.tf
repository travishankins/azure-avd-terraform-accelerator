variable "enable_policies" {
  description = "Enable Azure Policy assignments for governance"
  type        = bool
  default     = false
}

variable "resource_group_id" {
  description = "Resource group ID for policy assignment"
  type        = string
}

variable "location" {
  description = "Azure region for managed identity policies"
  type        = string
}

variable "allowed_vm_sizes" {
  description = "List of allowed VM sizes for AVD session hosts"
  type        = list(string)
  default = [
    "Standard_D2s_v5",
    "Standard_D4s_v5",
    "Standard_D8s_v5",
    "Standard_D16s_v5",
    "Standard_D2ds_v5",
    "Standard_D4ds_v5",
    "Standard_D8ds_v5"
  ]
}

variable "require_environment_tag" {
  description = "Require Environment tag on all resources"
  type        = bool
  default     = true
}

variable "deploy_antimalware" {
  description = "Deploy Microsoft Antimalware extension via policy"
  type        = bool
  default     = true
}

variable "audit_disk_encryption" {
  description = "Audit VMs without disk encryption enabled"
  type        = bool
  default     = true
}

variable "enable_vm_diagnostics" {
  description = "Enable diagnostic settings for VMs"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = ""
}
