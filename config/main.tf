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
  subscription_id = var.subscription_id
  client_id       = "e9d604e7-6d1b-41dc-9203-bffd0162d0d4"
  client_secret   = var.client_secret
  tenant_id       = "4734682f-19bb-4f97-8b05-01b29e62d28f"
}

resource "azurerm_resource_group" "rg_westeu_001" {
  name     = "rg-westeu-001"
  location = "westeurope"
  tags     = var.tags_project_cv
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg-westeu-001"
  location            = azurerm_resource_group.rg_westeu_001.location
  resource_group_name = azurerm_resource_group.rg_westeu_001.name
  tags                = var.tags_project_cv
}

resource "azurerm_network_security_rule" "nsg_rule1" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_public_ip
  destination_address_prefix  = azurerm_network_interface.vnic1.private_ip_address
  resource_group_name         = azurerm_resource_group.rg_westeu_001.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_network_security_rule" "nsg_rule2" {
  name                        = "AllowHTTP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = azurerm_network_interface.vnic1.private_ip_address
  resource_group_name         = azurerm_resource_group.rg_westeu_001.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_network_security_rule" "nsg_rule3" {
  name                        = "AllowHTTPS"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = azurerm_network_interface.vnic1.private_ip_address
  resource_group_name         = azurerm_resource_group.rg_westeu_001.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_virtual_network" "vnet_westeu_001" {
  name                = "vnet-westeu-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_westeu_001.location
  resource_group_name = azurerm_resource_group.rg_westeu_001.name
  tags                = var.tags_project_cv
}

resource "azurerm_subnet" "gwsnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg_westeu_001.name
  virtual_network_name = azurerm_virtual_network.vnet_westeu_001.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "snet1" {
  name                 = "snet1"
  resource_group_name  = azurerm_resource_group.rg_westeu_001.name
  virtual_network_name = azurerm_virtual_network.vnet_westeu_001.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_interface" "vnic1" {
  name                = "vnic1"
  location            = azurerm_resource_group.rg_westeu_001.location
  resource_group_name = azurerm_resource_group.rg_westeu_001.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet1.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags_project_cv
}

resource "tls_private_key" "ssh_talosrobert" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "vm-linux-westeu-001"
  resource_group_name             = azurerm_resource_group.rg_westeu_001.name
  location                        = azurerm_resource_group.rg_westeu_001.location
  size                            = "Standard_B1s"
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vnic1.id]

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
    name                 = "mcmc5dnprwkzi7kv9jsgguo4t9hqwsuoq29i5mwbbsrxkbywjagzrrja5hqtepq"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal-daily"
    sku       = "20_04-daily-lts-gen2"
    version   = "20.04.202204040"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_talosrobert.public_key_openssh
  }

  tags = var.tags_project_cv
}

resource "azurerm_public_ip" "pip1" {
  name                = "pip-westeu-001"
  resource_group_name = azurerm_resource_group.rg_westeu_001.name
  location            = azurerm_resource_group.rg_westeu_001.location
  allocation_method   = "Dynamic"
  domain_name_label   = "nwaibokd3xgdgdgcb2bjsx3box5crrabhurkaqg2i4tdyecaviopkzk33kt9uja"
  sku                 = "Basic"
  tags                = var.tags_project_cv
}

resource "azurerm_lb" "lb_westeu_001" {
  name                = "lb-westeu-001"
  location            = azurerm_resource_group.rg_westeu_001.location
  resource_group_name = azurerm_resource_group.rg_westeu_001.name
  frontend_ip_configuration {
    name                 = "pip1"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

  tags = var.tags_project_cv
}

resource "azurerm_lb_nat_rule" "nat_rule1" {
  resource_group_name            = azurerm_resource_group.rg_westeu_001.name
  loadbalancer_id                = azurerm_lb.lb_westeu_001.id
  name                           = "SSH"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "pip1"
}

resource "azurerm_network_interface_nat_rule_association" "nat_assoc1" {
  network_interface_id  = azurerm_network_interface.vnic1.id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.nat_rule1.id
}