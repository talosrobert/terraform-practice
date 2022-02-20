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
    Environment = "Testing"
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
    security_group = azurerm_network_security_group.nsg1.id
  }

  subnet {
    name           = "snet-test-westeurope-002"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.nsg1.id
  }

  subnet {
    name           = "snet-test-westeurope-003"
    address_prefix = "10.0.3.0/24"
    security_group = azurerm_network_security_group.nsg2.id
  }

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg-test-westeurope-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-inbound-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "nsg-test-westeurope-002"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-inbound-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.3.0/24"
  }

  security_rule {
    name                       = "allow-inbound-htts"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.3.0/24"
  }

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_watcher" "nw" {
  name                = "nw-test-westeurope-001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = "Testing"
  }
}