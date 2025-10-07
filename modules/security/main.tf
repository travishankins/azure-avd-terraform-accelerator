# Security Module for AVD Environment
# This module creates Key Vault and manages secrets

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "main" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name
  
  # Enable Azure Services access
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  
  # Soft delete and purge protection
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  
  # Network access rules
  network_acls {
    default_action = var.network_acls_default_action
    bypass         = var.network_acls_bypass
    
    # Allow access from specific IP ranges
    ip_rules = var.allowed_ip_ranges
    
    # Allow access from specific subnets
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  # Access policy for current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    
    secret_permissions = var.admin_secret_permissions
    key_permissions    = var.admin_key_permissions
    certificate_permissions = var.admin_certificate_permissions
  }

  tags = var.tags
}

# Additional access policies for specified users/service principals
resource "azurerm_key_vault_access_policy" "additional" {
  for_each = var.additional_access_policies
  
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id
  
  secret_permissions      = each.value.secret_permissions
  key_permissions         = each.value.key_permissions
  certificate_permissions = each.value.certificate_permissions
}

# Generate admin password if not provided
resource "random_password" "vm_admin" {
  count   = var.generate_admin_password ? 1 : 0
  length  = var.admin_password_length
  special = var.admin_password_special_chars
  upper   = var.admin_password_upper_chars
  lower   = var.admin_password_lower_chars
  numeric = var.admin_password_numeric_chars
}

# Store admin password in Key Vault
resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = var.admin_password_secret_name
  value        = var.admin_password != null ? var.admin_password : (var.generate_admin_password ? random_password.vm_admin[0].result : "")
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Note: Additional secrets can be added manually after deployment
# to avoid sensitive value issues with for_each

# Key Vault Private Endpoint (optional)
resource "azurerm_private_endpoint" "key_vault" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  tags = var.tags
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "key_vault" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Private DNS Zone Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "${var.key_vault_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault[0].name
  virtual_network_id    = var.virtual_network_id
  tags                  = var.tags
}

# Private DNS A Record
resource "azurerm_private_dns_a_record" "key_vault" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = var.key_vault_name
  zone_name           = azurerm_private_dns_zone.key_vault[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.key_vault[0].private_service_connection[0].private_ip_address]
  tags                = var.tags
}