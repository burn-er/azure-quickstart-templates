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

resource "random_integer" "rnd_int" {
  min = 1
  max = 10000
}

resource random_string "password" {
  length      = 16
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}

resource "azurerm_sql_firewall_rule" "example" {
  name                = "firewall-rule"
  resource_group_name = "testrg"
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = "10.0.17.62"
  end_ip_address      = "10.0.17.62"
}

resource "azurerm_storage_account" "example" {
  name                     = "sa${random_integer.rnd_int.result}"
  resource_group_name      = "testrg"
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

resource "azurerm_sql_server" "example" {
  name                         = "sqlserver-${random_integer.rnd_int.result}"
  resource_group_name          = "testrg"
  location                     = "East US"
  version                      = "12.0"
  administrator_login          = "ariel"
  administrator_login_password = "Aa12345678"
}

resource "azurerm_mssql_server_security_alert_policy" "example" {
  resource_group_name        = "testrg"
  server_name                = azurerm_sql_server.example.name
  state                      = "Enabled"
  storage_endpoint           = azurerm_storage_account.example.primary_blob_endpoint
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  disabled_alerts = [
    "Sql_Injection",
    "Data_Exfiltration"
  ]
  retention_days = 20
}

resource "azurerm_mysql_server" "example" {
  name                = "mysql-${random_integer.rnd_int.result}"
  location            = "East US"
  resource_group_name = "testrg"

  administrator_login          = "FGdfgbv"
  administrator_login_password = random_string.password.result

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
}

resource "azurerm_postgresql_server" "example" {
  name                         = "postgresql-${random_integer.rnd_int.result}"
  location                     = "East US"
  resource_group_name          = "testrg"
  sku_name                     = "B_Gen5_2"
  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  administrator_login          = "DKFJnisdfu"
  administrator_login_password = "Aa12345678"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_configuration" "thrtottling_config" {
  name                = "connection_throttling"
  resource_group_name = "testrg"
  server_name         = azurerm_postgresql_server.example.name
  value               = "off"
}

resource "azurerm_postgresql_configuration" "example" {
  name                = "log_checkpoints"
  resource_group_name = "testrg"
  server_name         = azurerm_postgresql_server.example.name
  value               = "on"
}