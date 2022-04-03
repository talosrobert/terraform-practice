terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "1ec72e10-9892-4932-927d-fca996abd309"
}

resource "azurerm_resource_group" "rg_app_weu_001" {
  name     = "rg-app-weu-001"
  location = "westeurope"

  tags = var.tags
}

resource "azurerm_service_plan" "asp_app_weu_001" {
  name                = "asp-app-weu-001"
  resource_group_name = azurerm_resource_group.rg_app_weu_001.name
  location            = "West Europe"
  os_type             = "Linux"
  sku_name            = "F1"

  tags = var.tags
}

resource "azurerm_linux_web_app" "app_weu_001" {
  name                = "ruue5c9ojcvtmf95b2zityru"
  resource_group_name = azurerm_resource_group.rg_app_weu_001.name
  location            = azurerm_service_plan.asp_app_weu_001.location
  service_plan_id     = azurerm_service_plan.asp_app_weu_001.id
  https_only          = true

  site_config {
    always_on         = false
    use_32_bit_worker = true
    application_stack {
      python_version = "3.9"
    }
  }

  tags = var.tags
}