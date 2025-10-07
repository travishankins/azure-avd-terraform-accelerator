# Variables for the Networking Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# VNet Configuration - Create New or Use Existing
variable "use_existing_vnet" {
  description = "Whether to use an existing VNet instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_vnet_name" {
  description = "Name of existing VNet (required if use_existing_vnet is true)"
  type        = string
  default     = ""
}

variable "existing_vnet_resource_group" {
  description = "Resource group of existing VNet (required if use_existing_vnet is true)"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "Name of the virtual network (used when creating new VNet)"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network (used when creating new VNet)"
  type        = list(string)
}

# Subnet Configuration
variable "create_new_subnet" {
  description = "Whether to create a new subnet (true) or use existing subnet (false)"
  type        = bool
  default     = true
}

variable "existing_subnet_name" {
  description = "Name of existing subnet (required if create_new_subnet is false)"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "Name of the AVD subnet (used when creating new subnet)"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the AVD subnet (used when creating new subnet)"
  type        = list(string)
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
}

variable "corporate_network_cidr" {
  description = "CIDR block for corporate network (for NSG rules)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}