# Monitoring Module for AVD Environment
# This module creates Log Analytics workspace and diagnostic settings

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  
  daily_quota_gb                     = var.daily_quota_gb
  internet_ingestion_enabled         = var.internet_ingestion_enabled
  internet_query_enabled             = var.internet_query_enabled
  reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day
  
  tags = var.tags
}

# Log Analytics Solutions
resource "azurerm_log_analytics_solution" "updates" {
  count                 = var.enable_update_management ? 1 : 0
  solution_name         = "Updates"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "security" {
  count                 = var.enable_security_center ? 1 : 0
  solution_name         = "Security"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = var.tags
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "main" {
  count               = length(var.notification_emails) > 0 ? 1 : 0
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  dynamic "email_receiver" {
    for_each = var.notification_emails
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  tags = var.tags
}

# Metric Alerts
resource "azurerm_monitor_metric_alert" "cpu_high" {
  count               = var.enable_metric_alerts && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                = "${var.resource_prefix}-high-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "High CPU usage alert for AVD session hosts"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = length(var.notification_emails) > 0 ? azurerm_monitor_action_group.main[0].id : null
  }

  frequency   = "PT5M"
  window_size = "PT15M"
  severity    = 2

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "memory_high" {
  count               = var.enable_metric_alerts && length(var.vm_resource_ids) > 0 ? 1 : 0
  name                = "${var.resource_prefix}-high-memory-alert"
  resource_group_name = var.resource_group_name
  scopes              = var.vm_resource_ids
  description         = "High memory usage alert for AVD session hosts"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.memory_alert_threshold_bytes
  }

  action {
    action_group_id = length(var.notification_emails) > 0 ? azurerm_monitor_action_group.main[0].id : null
  }

  frequency   = "PT5M"
  window_size = "PT15M"
  severity    = 2

  tags = var.tags
}

# Application Insights for AVD (optional)
resource "azurerm_application_insights" "main" {
  count               = var.enable_application_insights ? 1 : 0
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = var.tags
}