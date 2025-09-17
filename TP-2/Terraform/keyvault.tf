# Récupération du tenant / object_id du compte Terraform
data "azurerm_client_config" "current" {}

# Configure the Azure Key Vault
resource "azurerm_key_vault" "meow_vault" {
  name                       = "kv-${var.resource_group_name}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_linux_virtual_machine.main.identity[0].principal_id
    secret_permissions = [
      "Get", "List"
    ]
  }
}

# Génère un mot de passe de 16 caractères
resource "random_password" "meow_secret" {
  length           = 16
  special          = true
  override_special = "@#$%^&*()"
}

# Crée un Secret dans le Key Vault
resource "azurerm_key_vault_secret" "meow_secret" {
  name         = "meow-secret"
  value        = random_password.meow_secret.result
  key_vault_id = azurerm_key_vault.meow_vault.id
}


