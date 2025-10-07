variable "enable_image_gallery" {
  description = "Enable Shared Image Gallery for golden images"
  type        = bool
  default     = false
}

variable "gallery_name" {
  description = "Name of the Shared Image Gallery"
  type        = string
  default     = "sig_avd"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "gallery_description" {
  description = "Description of the Shared Image Gallery"
  type        = string
  default     = "AVD Golden Images for Session Hosts"
}

variable "create_win11_definition" {
  description = "Create Windows 11 Multi-Session image definition"
  type        = bool
  default     = true
}

variable "create_win10_definition" {
  description = "Create Windows 10 Multi-Session image definition"
  type        = bool
  default     = false
}

variable "win11_image_name" {
  description = "Name for Windows 11 image definition"
  type        = string
  default     = "win11-multisession-avd"
}

variable "win10_image_name" {
  description = "Name for Windows 10 image definition"
  type        = string
  default     = "win10-multisession-avd"
}

variable "image_publisher" {
  description = "Publisher name for image definitions"
  type        = string
  default     = "MicrosoftWindowsDesktop"
}

variable "image_builder_principal_id" {
  description = "Object ID of service principal for image building (CI/CD)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
