# Azure Backup Module for AVD Session Hosts
# Provides automated backup and disaster recovery capabilities

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Recovery Services Vault
resource "azurerm_recovery_services_vault" "main" {
  count               = var.enable_backup ? 1 : 0
  name                = var.recovery_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.recovery_vault_sku
  
  soft_delete_enabled = var.soft_delete_enabled
  
  tags = var.tags
}

# Backup Policy for VMs
resource "azurerm_backup_policy_vm" "main" {
  count               = var.enable_backup ? 1 : 0
  name                = var.backup_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main[0].name

  # Backup schedule
  timezone = var.backup_timezone
  
  backup {
    frequency = var.backup_frequency
    time      = var.backup_time
    weekdays  = var.backup_frequency == "Weekly" ? var.backup_weekdays : null
  }

  # Retention policy
  retention_daily {
    count = var.daily_retention_count
  }

  dynamic "retention_weekly" {
    for_each = var.weekly_retention_count > 0 ? [1] : []
    content {
      count    = var.weekly_retention_count
      weekdays = var.backup_retention_weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = var.monthly_retention_count > 0 ? [1] : []
    content {
      count    = var.monthly_retention_count
      weekdays = var.backup_retention_weekdays
      weeks    = ["First", "Last"]
    }
  }

  dynamic "retention_yearly" {
    for_each = var.yearly_retention_count > 0 ? [1] : []
    content {
      count    = var.yearly_retention_count
      weekdays = var.backup_retention_weekdays
      weeks    = ["First"]
      months   = ["January"]
    }
  }
}

# Protect VMs with Backup
resource "azurerm_backup_protected_vm" "main" {
  count               = var.enable_backup ? length(var.vm_ids) : 0
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main[0].name
  source_vm_id        = var.vm_ids[count.index]
  backup_policy_id    = azurerm_backup_policy_vm.main[0].id
}
