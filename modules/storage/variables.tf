# Variables for the Storage Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "account_tier" {
  description = "Tier of the storage account"
  type        = string
  default     = "Premium"
}

variable "account_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Kind of storage account"
  type        = string
  default     = "FileStorage"
}

variable "directory_type" {
  description = "Directory type for Azure Files authentication"
  type        = string
  default     = "AADKERB"
}

variable "network_rules_default_action" {
  description = "Default action for network rules"
  type        = string
  default     = "Allow"
}

variable "network_rules_bypass" {
  description = "Bypass rules for network access"
  type        = list(string)
  default     = ["AzureServices"]
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the storage account"
  type        = list(string)
  default     = []
}

variable "file_share_name" {
  description = "Name of the file share"
  type        = string
  default     = "fslogix"
}

variable "file_share_quota_gb" {
  description = "Quota for the file share in GB"
  type        = number
  default     = 1024
}

variable "file_share_access_tier" {
  description = "Access tier for the file share"
  type        = string
  default     = "Premium"
}

variable "file_share_metadata" {
  description = "Metadata for the file share"
  type        = map(string)
  default     = {}
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for storage account"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "Virtual network ID for private DNS zone link"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}