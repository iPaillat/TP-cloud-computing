# Configure Azure Monitor Action Group for alerts

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.resource_group_name}-alerts"
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "vm-alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email_address
  }
}

# CPU Metric Alert (using platform metrics)
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alert when CPU usage exceeds 70%"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Alerte mémoire - si RAM dispo < 512 Mo
resource "azurerm_monitor_metric_alert" "memory_alert" {
  name                = "memory-alert-${azurerm_linux_virtual_machine.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  scopes              = [azurerm_linux_virtual_machine.main.id]
  description         = "Alerte si la VM a moins de 512 Mo de RAM disponible"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 536870912  # 512 * 1024 * 1024 bytes
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
