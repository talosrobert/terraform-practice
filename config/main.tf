terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.96"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-test-westeurope-001"
  location = "westeurope"

  tags = {
    environment = "testing-westeurope"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-test-westeurope-001"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg.name

  subnet {
    name           = "snet-test-westeurope-001"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "snet-test-westeurope-002"
    address_prefix = "10.0.2.0/24"
  }

  subnet {
    name           = "snet-test-westeurope-003"
    address_prefix = "10.0.3.0/24"
  }
}


