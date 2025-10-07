# Shared Image Gallery Module for AVD Golden Images
# Provides versioned image management and distribution

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

# Shared Image Gallery
resource "azurerm_shared_image_gallery" "main" {
  count               = var.enable_image_gallery ? 1 : 0
  name                = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.gallery_description

  tags = var.tags
}

# Image Definition for Windows 11 Multi-Session
resource "azurerm_shared_image" "win11_multisession" {
  count               = var.enable_image_gallery && var.create_win11_definition ? 1 : 0
  name                = var.win11_image_name
  gallery_name        = azurerm_shared_image_gallery.main[0].name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.image_publisher
    offer     = "Windows-11"
    sku       = "win11-22h2-avd"
  }

  purchase_plan {
    name      = "win11-22h2-avd"
    publisher = var.image_publisher
    product   = "Windows-11"
  }

  tags = var.tags
}

# Image Definition for Windows 10 Multi-Session
resource "azurerm_shared_image" "win10_multisession" {
  count               = var.enable_image_gallery && var.create_win10_definition ? 1 : 0
  name                = var.win10_image_name
  gallery_name        = azurerm_shared_image_gallery.main[0].name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  hyper_v_generation  = "V2"

  identifier {
    publisher = var.image_publisher
    offer     = "Windows-10"
    sku       = "win10-22h2-avd"
  }

  purchase_plan {
    name      = "win10-22h2-avd"
    publisher = var.image_publisher
    product   = "Windows-10"
  }

  tags = var.tags
}

# RBAC - Grant Contributor to Image Gallery for CI/CD
resource "azurerm_role_assignment" "image_contributor" {
  count                = var.enable_image_gallery && var.image_builder_principal_id != "" ? 1 : 0
  scope                = azurerm_shared_image_gallery.main[0].id
  role_definition_name = "Contributor"
  principal_id         = var.image_builder_principal_id
}
