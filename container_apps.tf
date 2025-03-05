resource "azurerm_key_vault_secret" "acr_password" {
  name         = "acr-admin-password"
  value        = data.azurerm_container_registry.acr.admin_password
  key_vault_id = "/subscriptions/4262cbc1-95ba-4586-943d-7570b5952c3b/resourceGroups/c2c-demo/providers/Microsoft.KeyVault/vaults/budgeto-vault"
}
resource "azurerm_container_app" "backend_containerapp" {
  for_each = { for app in var.container_apps : app.name => app }

  name                         = each.value.name
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = azurerm_key_vault_secret.acr_password.name
  }

  template {
    container {
      name   = each.value.name
      image  = "${var.acr_login_server}/${each.value.image_name}:${each.value.image_tag}"
      cpu    = 1
      memory = "2Gi"

      dynamic "env" {
        for_each = local.combined_env_vars
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = each.value.port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [data.azurerm_container_app_environment.main, azurerm_postgresql_flexible_server_database.new_db]
}

resource "azurerm_container_app" "frontend_containerapp" {
  name                         = "frontend-app"
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = azurerm_key_vault_secret.acr_password.name
  }

  template {
    container {
      name   = "frontend"
      image  = "${var.acr_login_server}/tfui:4"
      cpu    = 1
      memory = "2Gi"

      env {
        name  = "C2C_APP_API_ENDPOINT"
        value = "https://${azurerm_container_app.backend_containerapp["benoenv"].ingress[0].fqdn}/c2c_service"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  depends_on = [data.azurerm_container_app_environment.main, azurerm_container_app.backend_containerapp]
}