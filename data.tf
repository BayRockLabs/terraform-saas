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