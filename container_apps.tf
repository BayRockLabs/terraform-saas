resource "azurerm_container_app" "backend_containerapp" {
  for_each = { for app in var.container_apps : app.name => app }

  name                         = each.value.name
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"
  secret {
    name  = "acr-username"
    value = var.acr_admin_username
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }
  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
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

  secret {
    name  = "acr-username"
    value = var.acr_admin_username
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
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