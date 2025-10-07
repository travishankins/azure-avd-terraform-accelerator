# Variables for the AVD Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Host Pool Configuration
variable "host_pool_name" {
  description = "Name of the AVD host pool"
  type        = string
}

variable "host_pool_type" {
  description = "Type of host pool (Personal or Pooled)"
  type        = string
  default     = "Pooled"
  
  validation {
    condition     = contains(["Personal", "Pooled"], var.host_pool_type)
    error_message = "Host pool type must be either Personal or Pooled."
  }
}

variable "load_balancer_type" {
  description = "Load balancer type for the host pool"
  type        = string
  default     = "BreadthFirst"
  
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.load_balancer_type)
    error_message = "Load balancer type must be BreadthFirst, DepthFirst, or Persistent."
  }
}

variable "maximum_sessions_allowed" {
  description = "Maximum number of sessions allowed per session host"
  type        = number
  default     = 10
  
  validation {
    condition     = var.maximum_sessions_allowed > 0 && var.maximum_sessions_allowed <= 50
    error_message = "Maximum sessions allowed must be between 1 and 50."
  }
}

variable "start_vm_on_connect" {
  description = "Enable Start VM on Connect feature"
  type        = bool
  default     = true
}

variable "validate_environment" {
  description = "Enable validation environment for the host pool"
  type        = bool
  default     = false
}

variable "preferred_app_group_type" {
  description = "Preferred application group type"
  type        = string
  default     = "Desktop"
}

variable "custom_rdp_properties" {
  description = "Custom RDP properties for the host pool"
  type        = string
  default     = "audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:*;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2"
}

variable "host_pool_description" {
  description = "Description for the host pool"
  type        = string
  default     = null
}

variable "host_pool_friendly_name" {
  description = "Friendly name for the host pool"
  type        = string
  default     = null
}

variable "personal_desktop_assignment_type" {
  description = "Personal desktop assignment type (Automatic or Direct)"
  type        = string
  default     = "Automatic"
  
  validation {
    condition     = contains(["Automatic", "Direct"], var.personal_desktop_assignment_type)
    error_message = "Personal desktop assignment type must be Automatic or Direct."
  }
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

variable "desktop_application_group_name" {
  description = "Name of the desktop application group"
  type        = string
  default     = null
}

variable "desktop_application_group_friendly_name" {
  description = "Friendly name for the desktop application group"
  type        = string
  default     = null
}

variable "desktop_application_group_description" {
  description = "Description for the desktop application group"
  type        = string
  default     = null
}

variable "create_remote_app_application_group" {
  description = "Create remote app application group"
  type        = bool
  default     = false
}

variable "remote_app_application_group_name" {
  description = "Name of the remote app application group"
  type        = string
  default     = null
}

variable "remote_app_application_group_friendly_name" {
  description = "Friendly name for the remote app application group"
  type        = string
  default     = null
}

variable "remote_app_application_group_description" {
  description = "Description for the remote app application group"
  type        = string
  default     = null
}

# Remote Applications
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

# Workspace Configuration
variable "workspace_name" {
  description = "Name of the AVD workspace"
  type        = string
}

variable "workspace_friendly_name" {
  description = "Friendly name for the workspace"
  type        = string
  default     = null
}

variable "workspace_description" {
  description = "Description for the workspace"
  type        = string
  default     = null
}

# Scaling Plan Configuration
variable "enable_scaling_plan" {
  description = "Enable scaling plan for the host pool"
  type        = bool
  default     = false
}

variable "scaling_plan_name" {
  description = "Name of the scaling plan"
  type        = string
  default     = null
}

variable "scaling_plan_friendly_name" {
  description = "Friendly name for the scaling plan"
  type        = string
  default     = null
}

variable "scaling_plan_description" {
  description = "Description for the scaling plan"
  type        = string
  default     = null
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}