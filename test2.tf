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

resource "azurerm_virtual_network" "example2" {
  name                = "vn2"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "testrg2"
}

resource "azurerm_subnet" "example2" {
  name                 = "subnet2"
  resource_group_name = "testrg2"
  virtual_network_name = azurerm_virtual_network.example2.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "ni_linux2" {
  name                = "linux2"
  location            = "East US"
  resource_group_name = "testrg2"
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example2.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface" "ni_win2" {
  name                = "win2"
  location            = "East US"
  resource_group_name = "testrg2"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource azurerm_network_watcher "network_watcher2" {
  location            = "East US"
  name                = "network-watcher2"
  resource_group_name = "testrg2"
}

resource azurerm_network_security_group "bad_sg2" {
  location            = "East US"
  name                = "nsg2"
  resource_group_name = "testrg2"

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowSSH"
    priority                   = 200
    protocol                   = "TCP"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "22-22"
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "AllowRDP"
    priority                   = 300
    protocol                   = "TCP"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "3389-3389"
    destination_address_prefix = "*"
  }
}

resource azurerm_network_watcher_flow_log "flow_log2" {
  enabled                   = false
  network_security_group_id = azurerm_network_security_group.bad_sg2.id
  network_watcher_name      = azurerm_network_watcher.network_watcher2.name
  resource_group_name       = "testrg2"
  storage_account_id        = azurerm_storage_account.example2.id
  retention_policy {
    enabled = false
    days    = 10
  }
}

resource "azurerm_storage_account" "example2" {
  name                     = "sa${random_integer.rnd_int.result}2"
  resource_group_name      = "testrg2"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  queue_properties {
    logging {
      delete                = false
      read                  = false
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}

resource "random_integer" "rnd_int" {
  min     = 1
  max     = 10000
}