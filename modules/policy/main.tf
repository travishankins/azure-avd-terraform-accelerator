# Azure Policy Module for AVD Governance
# Enforces compliance, security, and operational standards

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Policy Assignment - Require Managed Disks
resource "azurerm_resource_group_policy_assignment" "require_managed_disks" {
  count                = var.enable_policies ? 1 : 0
  name                 = "require-managed-disks"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  description          = "Ensure all VMs use managed disks"
  display_name         = "AVD - Require Managed Disks"
}

# Policy Assignment - Allowed VM SKUs
resource "azurerm_resource_group_policy_assignment" "allowed_vm_sizes" {
  count                = var.enable_policies && length(var.allowed_vm_sizes) > 0 ? 1 : 0
  name                 = "allowed-vm-sizes"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3"
  description          = "Restrict VM sizes to approved list"
  display_name         = "AVD - Allowed VM Sizes"

  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.allowed_vm_sizes
    }
  })
}

# Policy Assignment - Require Tag
resource "azurerm_resource_group_policy_assignment" "require_environment_tag" {
  count                = var.enable_policies && var.require_environment_tag ? 1 : 0
  name                 = "require-environment-tag"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  description          = "Require Environment tag on all resources"
  display_name         = "AVD - Require Environment Tag"

  parameters = jsonencode({
    tagName = {
      value = "Environment"
    }
  })
}

# Policy Assignment - Antimalware Extension
resource "azurerm_resource_group_policy_assignment" "deploy_antimalware" {
  count                = var.enable_policies && var.deploy_antimalware ? 1 : 0
  name                 = "deploy-antimalware"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/9b597639-28e4-48eb-b506-56b05d366257"
  description          = "Deploy Microsoft Antimalware extension to Windows VMs"
  display_name         = "AVD - Deploy Antimalware"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    InclusionExtensions = {
      value = ".txt,.exe,.dll,.msi"
    }
    ExclusionExtensions = {
      value = ".tmp"
    }
    RealtimeProtectionEnabled = {
      value = "true"
    }
    ScheduledScanSettingsIsEnabled = {
      value = "true"
    }
    ScheduledScanSettingsScanType = {
      value = "Quick"
    }
    ScheduledScanSettingsDay = {
      value = "7"
    }
    ScheduledScanSettingsTime = {
      value = "120"
    }
  })
}

# Role Assignment for Antimalware Policy
resource "azurerm_role_assignment" "antimalware_contributor" {
  count                = var.enable_policies && var.deploy_antimalware ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_resource_group_policy_assignment.deploy_antimalware[0].identity[0].principal_id
}

# Policy Assignment - Monitor Unencrypted VMs
resource "azurerm_resource_group_policy_assignment" "audit_vm_encryption" {
  count                = var.enable_policies && var.audit_disk_encryption ? 1 : 0
  name                 = "audit-vm-encryption"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0961003e-5a0a-4549-abde-af6a37f2724d"
  description          = "Audit VMs without disk encryption"
  display_name         = "AVD - Audit VM Encryption"
}

# Policy Assignment - Diagnostic Settings for VMs
resource "azurerm_resource_group_policy_assignment" "vm_diagnostic_settings" {
  count                = var.enable_policies && var.enable_vm_diagnostics && var.log_analytics_workspace_id != "" ? 1 : 0
  name                 = "vm-diagnostic-settings"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/339353f6-2387-4a45-abe4-7f529d121046"
  description          = "Deploy diagnostic settings for VMs to Log Analytics"
  display_name         = "AVD - VM Diagnostic Settings"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    logAnalyticsWorkspaceId = {
      value = var.log_analytics_workspace_id
    }
  })
}

# Role Assignment for Diagnostic Settings Policy
resource "azurerm_role_assignment" "diagnostics_contributor" {
  count                = var.enable_policies && var.enable_vm_diagnostics && var.log_analytics_workspace_id != "" ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_resource_group_policy_assignment.vm_diagnostic_settings[0].identity[0].principal_id
}
