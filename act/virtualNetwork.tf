terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "testrg"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vn-test"
  address_space       = ["10.0.0.0/16"]
  location            = "East US"
  resource_group_name = "testrg"
}

resource "azurerm_subnet" "example" {
  name                 = "subnet-test"
  resource_group_name  = "testrg"
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "ni_linux" {
  name                = "linux-test"
  location            = "East US"
  resource_group_name = "testrg"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "ni_win" {
  name                = "win-test"
  location            = "East US"
  resource_group_name = "testrg"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource azurerm_network_security_group "bad_sg" {
  location            = "East US"
  name                = "test-nsg"
  resource_group_name = "testrg"
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

resource "azurerm_storage_account" "my_storage" {
  name                     = "functionsapptestsa"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  queue_properties {
    logging {
      write                 = true
      read                  = true
      version               = "1.0"
      retention_policy_days = 365
      delete                = true
    }
    hour_metrics {
      enabled               = true
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 365
    }
    minute_metrics {
      version               = "1.0"
      include_apis          = true
      retention_policy_days = 365
      enabled               = true
    }
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "test-azure-functions"
  location                   = azurerm_resource_group.resource_group.location
  resource_group_name        = azurerm_resource_group.resource_group.name
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  storage_account_name       = azurerm_storage_account.my_storage.name
  storage_account_access_key = azurerm_storage_account.my_storage.primary_access_key

  auth_settings {
    enabled = true
  }

  site_config {
    ftps_state = "Disabled"
  }
}
