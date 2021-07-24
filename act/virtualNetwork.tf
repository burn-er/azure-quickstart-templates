terraform {

required_providers {

azurerm = {

source = "hashicorp/azurerm"

version = "~>2.0"

}

}

}

provider "azurerm" {

features {}

}



resource "azurerm_virtual_network" "example" {

name = "vn-test"

address_space = ["10.0.0.0/16"]

location = "East US"

resource_group_name = "testrg"

}



resource "azurerm_subnet" "example" {

name = "subnet-test"

resource_group_name = "testrg"

virtual_network_name = azurerm_virtual_network.example.name

address_prefixes = ["10.0.0.0/24"]

}



resource "azurerm_network_interface" "ni_linux" {

name = "linux-test"

location = "East US"

resource_group_name = "testrg"



ip_configuration {

name = "internal"

subnet_id = azurerm_subnet.example.id

private_ip_address_allocation = "Dynamic"

}

}



resource "azurerm_network_interface" "ni_win" {

name = "win-test"

location = "East US"

resource_group_name = "testrg"



ip_configuration {

name = "internal"

subnet_id = azurerm_subnet.example.id

private_ip_address_allocation = "Dynamic"

}

}



resource azurerm_network_security_group "bad_sg" {

location = "East US"

name = "test-nsg"

resource_group_name = "testrg"



security_rule {

access = "Allow"

direction = "Inbound"

name = "AllowSSH"

priority = 200

protocol = "TCP"

source_address_prefix = "*"

source_port_range = "*"

destination_port_range = "22-22"

destination_address_prefix = "*"

}



security_rule {

access = "Allow"

direction = "Inbound"

name = "AllowRDP"

priority = 300

protocol = "TCP"

source_address_prefix = "*"

source_port_range = "*"

destination_port_range = "3389-3389"

destination_address_prefix = "*"

}

}
