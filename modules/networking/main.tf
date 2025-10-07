# Networking Module for AVD Environment
# This module creates or uses existing virtual network, subnet, and network security group

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Data source for existing VNet (used when use_existing_vnet is true)
data "azurerm_virtual_network" "existing" {
  count               = var.use_existing_vnet ? 1 : 0
  name                = var.existing_vnet_name
  resource_group_name = var.existing_vnet_resource_group
}

# Data source for existing subnet (used when create_new_subnet is false)
data "azurerm_subnet" "existing" {
  count                = !var.create_new_subnet ? 1 : 0
  name                 = var.existing_subnet_name
  virtual_network_name = var.use_existing_vnet ? var.existing_vnet_name : azurerm_virtual_network.main[0].name
  resource_group_name  = var.use_existing_vnet ? var.existing_vnet_resource_group : var.resource_group_name
}

# Create new Virtual Network (only when use_existing_vnet is false)
resource "azurerm_virtual_network" "main" {
  count               = var.use_existing_vnet ? 0 : 1
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Network Security Group for AVD subnet
resource "azurerm_network_security_group" "avd_nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow RDP from corporate network
  security_rule {
    name                       = "AllowRDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.corporate_network_cidr
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow WVD service traffic
  security_rule {
    name                       = "AllowWVDService"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "WindowsVirtualDesktop"
  }

  tags = var.tags
}

# Subnet for AVD (only when create_new_subnet is true)
resource "azurerm_subnet" "avd_subnet" {
  count                = var.create_new_subnet ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = var.use_existing_vnet ? var.existing_vnet_resource_group : var.resource_group_name
  virtual_network_name = var.use_existing_vnet ? var.existing_vnet_name : azurerm_virtual_network.main[0].name
  address_prefixes     = var.subnet_address_prefixes
}

# Associate NSG with subnet (works with both new and existing subnets)
resource "azurerm_subnet_network_security_group_association" "avd_subnet_nsg" {
  subnet_id                 = var.create_new_subnet ? azurerm_subnet.avd_subnet[0].id : data.azurerm_subnet.existing[0].id
  network_security_group_id = azurerm_network_security_group.avd_nsg.id
}