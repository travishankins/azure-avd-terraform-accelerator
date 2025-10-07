# Storage Module for AVD Environment
# This module creates the storage account and file share for FSLogix profiles

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Storage Account for FSLogix profiles
resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  
  # Configure for FSLogix
  azure_files_authentication {
    directory_type = var.directory_type
  }

  # Network access rules
  network_rules {
    default_action = var.network_rules_default_action
    bypass         = var.network_rules_bypass
    
    # Allow access from AVD subnet
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# File Share for FSLogix
resource "azurerm_storage_share" "fslogix" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.main.name
  quota                = var.file_share_quota_gb
  access_tier          = var.file_share_access_tier
  
  metadata = var.file_share_metadata
}

# Optional: Storage Account Private Endpoint
resource "azurerm_private_endpoint" "storage" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.storage_account_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Optional: Private DNS Zone for Storage Account
resource "azurerm_private_dns_zone" "storage" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "${var.storage_account_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage[0].name
  virtual_network_id    = var.virtual_network_id
  tags                  = var.tags
}

# Private DNS A Record
resource "azurerm_private_dns_a_record" "storage" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.storage_account_name
  zone_name           = azurerm_private_dns_zone.storage[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage[0].private_service_connection[0].private_ip_address]
  tags                = var.tags
}