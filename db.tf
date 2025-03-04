resource "azurerm_postgresql_flexible_server_database" "new_db" {
  name      = var.db_name
  server_id = data.azurerm_postgresql_flexible_server.existing_flexible.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [data.azurerm_resource_group.main]
}