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

resource "azurerm_resource_group" "rg1" {
  name     = "we-test-rg-001"
  location = "westeurope"

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "we-test-vnet-001"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.rg1.name

  subnet {
    name           = "AzureFirewallSubnet"
    address_prefix = "10.0.0.0/24"
  }

  subnet {
    name           = "we-test-snet-001"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.nsg1.id
  }

  subnet {
    name           = "we-test-snet-002"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.nsg2.id
  }

  subnet {
    name           = "we-test-snet-003"
    address_prefix = "10.0.3.0/24"
    security_group = azurerm_network_security_group.nsg3.id
  }

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "we-test-nsg-001"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_security_group" "nsg2" {
  name                = "we-test-nsg-002"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_security_group" "nsg3" {
  name                = "we-test-nsg-003"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_network_watcher" "nw" {
  name                = "we-test-nw-001"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_public_ip" "pip1" {
  name                = "we-test-pip-001"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Testing"
  }
}

resource "azurerm_firewall" "afw1" {
  name                = "we-test-afw-001"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  sku_tier            = "Standard"
  dns_servers         = ["9.9.9.9", "149.112.112.112"]

  ip_configuration {
    name                 = "afw1-ipconf"
    subnet_id            = [for s in azurerm_virtual_network.vnet1.subnet : s.id if s.name == "AzureFirewallSubnet"][0]
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

  tags = {
    Environment = "Testing"
  }
}