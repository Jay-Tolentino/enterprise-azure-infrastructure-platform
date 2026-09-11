data "azurerm_client_config" "current" {}

locals {
  key_vault_name = "kv-eaip-${substr(md5(data.azurerm_client_config.current.subscription_id), 0, 8)}"
}

resource "azurerm_key_vault" "main" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = local.common_tags
}

resource "azurerm_role_assignment" "vm_key_vault_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.linux.identity[0].principal_id
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-enterprise-azure-dev"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.linux.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = local.common_tags
}

resource "azurerm_monitor_data_collection_rule" "linux" {
  name                = "dcr-linux-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "log-analytics"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics"]
  }

  data_sources {
    syslog {
      streams = ["Microsoft-Syslog"]

      facility_names = [
        "auth",
        "authpriv",
        "daemon",
        "syslog",
        "user"
      ]

      log_levels = [
        "Debug",
        "Info",
        "Notice",
        "Warning",
        "Error",
        "Critical",
        "Alert",
        "Emergency"
      ]

      name = "linux-syslog"
    }
  }

  tags = local.common_tags
}

resource "azurerm_monitor_data_collection_rule_association" "linux" {
  name                    = "dcra-linux-dev"
  target_resource_id      = azurerm_linux_virtual_machine.linux.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.linux.id
}

resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "alert-vm-linux-high-cpu"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.linux.id]
  description         = "Alert when Linux VM average CPU exceeds 80 percent."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  tags = local.common_tags
}