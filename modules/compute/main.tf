# Compute Module for AVD Session Hosts
# This module creates the session host VMs and their extensions

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Session Host Network Interfaces
resource "azurerm_network_interface" "session_host" {
  count               = var.session_host_count
  name                = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.session_host[count.index].id : null
  }

  accelerated_networking_enabled = var.enable_accelerated_networking
  ip_forwarding_enabled         = var.enable_ip_forwarding

  tags = var.tags
}

# Public IPs (optional)
resource "azurerm_public_ip" "session_host" {
  count               = var.enable_public_ip ? var.session_host_count : 0
  name                = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = var.tags
}

# Session Host Virtual Machines
resource "azurerm_windows_virtual_machine" "session_host" {
  count               = var.session_host_count
  name                = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
  zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index % length(var.availability_zones)] : null

  network_interface_ids = [
    azurerm_network_interface.session_host[count.index].id,
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  # Enable system assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Enable boot diagnostics
  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  # Custom data for initial configuration
  custom_data = var.custom_data

  tags = var.tags
}

# Additional Data Disks (optional)
resource "azurerm_managed_disk" "data_disk" {
  count                = var.enable_data_disk ? var.session_host_count : 0
  name                 = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  count              = var.enable_data_disk ? var.session_host_count : 0
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.session_host[count.index].id
  lun                = 0
  caching            = var.data_disk_caching
}

# Azure AD Join Extension
resource "azurerm_virtual_machine_extension" "aad_join" {
  count                = var.enable_aad_join ? var.session_host_count : 0
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

  tags = var.tags
}

# Domain Join Extension
resource "azurerm_virtual_machine_extension" "domain_join" {
  count                = var.enable_domain_join ? var.session_host_count : 0
  name                 = "DomainJoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = jsonencode({
    Name    = var.domain_name
    OUPath  = var.domain_ou_path
    User    = var.domain_join_username
    Restart = "true"
    Options = "3"
  })

  protected_settings = jsonencode({
    Password = var.domain_join_password
  })

  tags = var.tags
}

# AVD DSC Extension to register session hosts
resource "azurerm_virtual_machine_extension" "avd_dsc" {
  count                = var.session_host_count
  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.PowerShell"
  type                 = "DSC"
  type_handler_version = "2.77"

  settings = jsonencode({
    wmfVersion = "latest"
    configuration = {
      url      = var.avd_agent_package_url
      script   = "Configuration.ps1"
      function = "AddSessionHost"
    }
    configurationArguments = {
      hostPoolName          = var.host_pool_name
      registrationInfoToken = var.host_pool_registration_token
      aadJoin               = var.enable_aad_join
    }
  })

  depends_on = [
    azurerm_virtual_machine_extension.aad_join,
    azurerm_virtual_machine_extension.domain_join
  ]

  tags = var.tags
}

# Monitoring Agent Extension
resource "azurerm_virtual_machine_extension" "monitoring_agent" {
  count                = var.enable_monitoring_agent ? var.session_host_count : 0
  name                 = "MicrosoftMonitoringAgent"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"

  settings = jsonencode({
    workspaceId = var.log_analytics_workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = var.log_analytics_workspace_key
  })

  tags = var.tags
}

# Dependency Agent Extension
resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                = var.enable_dependency_agent ? var.session_host_count : 0
  name                 = "DependencyAgentWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                 = "DependencyAgentWindows"
  type_handler_version = "9.5"

  depends_on = [azurerm_virtual_machine_extension.monitoring_agent]

  tags = var.tags
}

# Custom Script Extension for additional configuration
resource "azurerm_virtual_machine_extension" "custom_script" {
  count                = var.enable_custom_script ? var.session_host_count : 0
  name                 = "CustomScriptExtension"
  virtual_machine_id   = azurerm_windows_virtual_machine.session_host[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris         = var.custom_script_file_uris
    commandToExecute = var.custom_script_command
  })

  protected_settings = var.custom_script_protected_settings != null ? jsonencode(var.custom_script_protected_settings) : null

  depends_on = [azurerm_virtual_machine_extension.avd_dsc]

  tags = var.tags
}

# Auto-shutdown for session hosts
resource "azurerm_dev_test_global_vm_shutdown_schedule" "session_host" {
  count              = var.enable_auto_shutdown ? var.session_host_count : 0
  virtual_machine_id = azurerm_windows_virtual_machine.session_host[count.index].id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled         = var.auto_shutdown_notification_enabled
    time_in_minutes = var.auto_shutdown_notification_time_minutes
    email           = var.auto_shutdown_notification_email
  }

  tags = var.tags
}