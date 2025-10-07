output "gallery_id" {
  description = "ID of the Shared Image Gallery"
  value       = var.enable_image_gallery ? azurerm_shared_image_gallery.main[0].id : null
}

output "gallery_name" {
  description = "Name of the Shared Image Gallery"
  value       = var.enable_image_gallery ? azurerm_shared_image_gallery.main[0].name : null
}

output "win11_image_id" {
  description = "ID of the Windows 11 image definition"
  value       = var.enable_image_gallery && var.create_win11_definition ? azurerm_shared_image.win11_multisession[0].id : null
}

output "win10_image_id" {
  description = "ID of the Windows 10 image definition"
  value       = var.enable_image_gallery && var.create_win10_definition ? azurerm_shared_image.win10_multisession[0].id : null
}
