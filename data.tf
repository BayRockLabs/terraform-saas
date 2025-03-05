data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_container_app_environment" "main" {
  name                = "c2c-demo"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_postgresql_flexible_server" "existing_flexible" {
  name                = var.db_server_name
  resource_group_name = var.resource_group_name
}
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}
data "azurerm_key_vault_secret" "acr-admin-password" {
  name         = "acr-admin-password"
  key_vault_id = "/subscriptions/4262cbc1-95ba-4586-943d-7570b5952c3b/resourceGroups/c2c-demo/providers/Microsoft.KeyVault/vaults/budgeto-vault"
}