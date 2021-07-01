terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.65.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"

  features {}
}

# Create a resource group
resource "azurerm_resource_group" "test" {
  name     = "terraform-rg"
  location = "West US"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "test" {
  name                = "terraform-vnet"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  address_space       = ["10.2.0.0/16"]
}

# Create a web-tier subnet within terraform-vnet1
resource "azurerm_subnet" "test-web" {
  name		             = "terraform-subnet-web-tier"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "terraform-vnet"
  address_prefixes       = ["10.2.1.0/27"]
}

# Create a app-tier subnet within terraform-vnet1
resource "azurerm_subnet" "test-app" {
  name		           = "terraform-subnet-app-tier"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "terraform-vnet"
  address_prefixes       = ["10.2.0.0/24"]
}

# Create NSG
resource "azurerm_network_security_group" "test-web"{
  name = "test-nsg-terraform"
  location = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  security_rule{
      name = "Port_8080"
      direction = "Inbound"
      priority = "350"
      access = "Allow"
      protocol = "Tcp"
      source_address_prefix = "*"
      source_port_range = "*"
      destination_address_prefix = "*"
      destination_port_range = "8080"
    }
}

# Create NSG
resource "azurerm_network_security_group" "test-app"{
  name = "test-nsg-terraform"
  location = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  security_rule{
      name = "Port_80"
      direction = "Inbound"
      priority = "350"
      access = "Allow"
      protocol = "Tcp"
      source_address_prefix = "10.2.1.0/27"
      source_port_range = "*"
      destination_address_prefix = "*"
      destination_port_range = "80"
    }
}

# Associate subnet with nsg
resource "azurerm_subnet_network_security_group_association" "test-web"{
  subnet_id = "${azurerm_subnet.test-web.id}"
  network_security_group_id = "${azurerm_network_security_group.test-web.id}" 
}

resource "azurerm_subnet_network_security_group_association" "test-app"{
  subnet_id = "${azurerm_subnet.test-app.id}"
  network_security_group_id = "${azurerm_network_security_group.test-app.id}" 
}