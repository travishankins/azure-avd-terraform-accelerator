# AVD Module for Azure Virtual Desktop Components
# This module creates the AVD host pool, workspace, and application group

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

# AVD Host Pool
resource "azurerm_virtual_desktop_host_pool" "main" {
  name                = var.host_pool_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type                             = var.host_pool_type
  load_balancer_type              = var.load_balancer_type
  maximum_sessions_allowed        = var.maximum_sessions_allowed
  start_vm_on_connect             = var.start_vm_on_connect
  validate_environment            = var.validate_environment
  preferred_app_group_type        = var.preferred_app_group_type
  custom_rdp_properties           = var.custom_rdp_properties
  description                     = var.host_pool_description
  friendly_name                   = var.host_pool_friendly_name
  
  # Personal assignment type for Personal host pools
  personal_desktop_assignment_type = var.host_pool_type == "Personal" ? var.personal_desktop_assignment_type : null

  tags = var.tags
}

# Generate registration token for host pool
resource "time_rotating" "avd_token" {
  rotation_days = var.registration_token_rotation_days
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "main" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.main.id
  expiration_date = time_rotating.avd_token.rotation_rfc3339
}

# AVD Application Groups
resource "azurerm_virtual_desktop_application_group" "desktop" {
  count               = var.create_desktop_application_group ? 1 : 0
  name                = var.desktop_application_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type         = "Desktop"
  host_pool_id = azurerm_virtual_desktop_host_pool.main.id
  friendly_name = var.desktop_application_group_friendly_name
  description   = var.desktop_application_group_description

  tags = var.tags
}

resource "azurerm_virtual_desktop_application_group" "remote_app" {
  count               = var.create_remote_app_application_group ? 1 : 0
  name                = var.remote_app_application_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  type         = "RemoteApp"
  host_pool_id = azurerm_virtual_desktop_host_pool.main.id
  friendly_name = var.remote_app_application_group_friendly_name
  description   = var.remote_app_application_group_description

  tags = var.tags
}

# Remote Apps (for RemoteApp application group)
resource "azurerm_virtual_desktop_application" "apps" {
  for_each = var.remote_applications
  
  name                         = each.key
  application_group_id         = var.create_remote_app_application_group ? azurerm_virtual_desktop_application_group.remote_app[0].id : null
  friendly_name               = each.value.friendly_name
  description                 = each.value.description
  path                        = each.value.path
  command_line_argument_policy = each.value.command_line_argument_policy
  command_line_arguments      = each.value.command_line_arguments
  show_in_portal              = each.value.show_in_portal
  icon_path                   = each.value.icon_path
  icon_index                  = each.value.icon_index
}

# AVD Workspace
resource "azurerm_virtual_desktop_workspace" "main" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  friendly_name = var.workspace_friendly_name
  description   = var.workspace_description

  tags = var.tags
}

# Associate Application Groups with Workspace
resource "azurerm_virtual_desktop_workspace_application_group_association" "desktop" {
  count                = var.create_desktop_application_group ? 1 : 0
  workspace_id         = azurerm_virtual_desktop_workspace.main.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop[0].id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "remote_app" {
  count                = var.create_remote_app_application_group ? 1 : 0
  workspace_id         = azurerm_virtual_desktop_workspace.main.id
  application_group_id = azurerm_virtual_desktop_application_group.remote_app[0].id
}

# Optional: Scaling Plan for Host Pool
resource "azurerm_virtual_desktop_scaling_plan" "main" {
  count               = var.enable_scaling_plan ? 1 : 0
  name                = var.scaling_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = var.scaling_plan_friendly_name
  description         = var.scaling_plan_description
  time_zone           = var.scaling_plan_time_zone

  dynamic "schedule" {
    for_each = var.scaling_plan_schedules
    content {
      name                                 = schedule.value.name
      days_of_week                        = schedule.value.days_of_week
      ramp_up_start_time                  = schedule.value.ramp_up_start_time
      ramp_up_load_balancing_algorithm    = schedule.value.ramp_up_load_balancing_algorithm
      ramp_up_minimum_hosts_percent       = schedule.value.ramp_up_minimum_hosts_percent
      ramp_up_capacity_threshold_percent  = schedule.value.ramp_up_capacity_threshold_percent
      peak_start_time                     = schedule.value.peak_start_time
      peak_load_balancing_algorithm       = schedule.value.peak_load_balancing_algorithm
      ramp_down_start_time                = schedule.value.ramp_down_start_time
      ramp_down_load_balancing_algorithm  = schedule.value.ramp_down_load_balancing_algorithm
      ramp_down_minimum_hosts_percent     = schedule.value.ramp_down_minimum_hosts_percent
      ramp_down_capacity_threshold_percent = schedule.value.ramp_down_capacity_threshold_percent
      ramp_down_force_logoff_users        = schedule.value.ramp_down_force_logoff_users
      ramp_down_stop_hosts_when           = schedule.value.ramp_down_stop_hosts_when
      ramp_down_wait_time_minutes         = schedule.value.ramp_down_wait_time_minutes
      ramp_down_notification_message      = schedule.value.ramp_down_notification_message
      off_peak_start_time                 = schedule.value.off_peak_start_time
      off_peak_load_balancing_algorithm   = schedule.value.off_peak_load_balancing_algorithm
    }
  }

  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.main.id
    scaling_plan_enabled = true
  }

  tags = var.tags
}