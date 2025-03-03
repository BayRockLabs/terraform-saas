variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}

variable "acr_resource_group_name" {
  description = "The resource group name of the Azure Container Registry"
  type        = string
}

variable "acr_login_server" {
  description = "The login server of the Azure Container Registry"
  type        = string
}

variable "acr_admin_username" {
  description = "The admin username of the Azure Container Registry"
  type        = string
}

variable "acr_admin_password" {
  description = "The admin password of the Azure Container Registry"
  type        = string
}

variable "container_apps" {
  description = "List of container apps with their respective image names, tags, and ports"
  type = list(object({
    name        = string
    image_name  = string
    image_tag   = string
    port        = number
  }))
}

variable "env_vars" {
  description = "List of environment variables"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "db_server_name" {
  description = "The name of the existing database server"
  type        = string
}

variable "db_username" {
  description = "The admin username of the database server"
  type        = string
}

variable "db_password" {
  description = "The admin password of the database server"
  type        = string
}

variable "db_name" {
  description = "The name of the new database to be created"
  type        = string
}

locals {
  combined_env_vars = concat(
    var.env_vars,
    [
      { name = "DB_HOSTNAME", value = "${var.db_server_name}.postgres.database.azure.com" },  # Use FQDN
      { name = "DB_USERNAME", value = var.db_username },
      { name = "DB_PASSWORD", value = var.db_password },
      { name = "DB_NAME", value = var.db_name },
      { name = "DB_PORT", value = "5432" }
    ]
  )
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_app_environment" "main" {
  name                = "my-container-app-environment"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  depends_on = [azurerm_resource_group.main]
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

data "azurerm_postgresql_flexible_server" "existing_flexible" {
  name                = var.db_server_name
  resource_group_name = "c2c-demo"
}

resource "azurerm_postgresql_flexible_server_database" "new_db" {
  name      = var.db_name
  server_id = data.azurerm_postgresql_flexible_server.existing_flexible.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [azurerm_resource_group.main]
}
resource "azurerm_container_app" "backend_containerapp" {
  for_each = { for app in var.container_apps : app.name => app }

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  secret {
    name  = "acr-username"
    value = var.acr_admin_username
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  dynamic "secret" {
    for_each = local.combined_env_vars
    content {
      name  = lower(replace(secret.value.name, "_", "-"))
      value = secret.value.value
    }
  }

  secret {
    name  = "db-hostname"
    value = data.azurerm_postgresql_flexible_server.existing_flexible.fqdn
  }

  secret {
    name  = "db-username"
    value = var.db_username
  }

  secret {
    name  = "db-password"
    value = var.db_password
  }

  secret {
    name  = "db-name"
    value = var.db_name
  }

  secret {
    name  = "db-port"
    value = "5432"
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

  depends_on = [azurerm_container_app_environment.main, azurerm_postgresql_flexible_server_database.new_db]
}

output "backend_containerapp_url" {
  value = azurerm_container_app.backend_containerapp["benoenv"].ingress[0].fqdn
}

resource "azurerm_container_app" "frontend_containerapp" {
  name                         = "frontend-app"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
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

     /* env {
        name  = "C2C_APP_SERVER_URL"
        value = "https://${azurerm_container_app.frontend_containerapp.ingress[0].fqdn}/"
      }
      */

      env {
        name  = "C2C_APP_API_ENDPOINT_AUTH_SERVICE"
        value = "https://auth-service.blackstone-feec0b94.eastus.azurecontainerapps.io/auth_service"
      }

      env {
        name  = "C2C_APP_API_ENDPOINT_EXTRACT_SERVICE"
        value = "https://brl-c2c-document-parser.blackstone-feec0b94.eastus.azurecontainerapps.io"
      }

      env {
        name  = "REACT_APP_CLIENT_ID"
        value = "5997dba0-9e0f-4d74-bd95-52bdb46a12e5"
      }

      env {
        name  = "REACT_APP_AUTHORITY_URL"
        value = "https://login.microsoftonline.com/c7d884f9-0fc9-43c7-8491-a7690ea021f5"
      }

      env {
        name  = "REACT_APP_PROFILE"
        value = "demo"
      }

      env {
        name  = "APP_ENABLED_PAST_DATES"
        value = "false"
      }

      env {
        name  = "REACT_APP_UNLOCKED_ESTIMATION_EDIT"
        value = "true"
      }

      env {
        name  = "REACT_APP_ENABLE_BILLRATE_EDIT"
        value = "true"
      }

      env {
        name  = "REACT_APP_BUSINESS_UNITS"
        value = "Startup, Enterprise, PMO, Biz Finance, Sales, Delivery Management, Executive Management, HR, Marketing, Recruitment, IT"
      }

      env {
        name  = "REACT_APP_ASSIGNED_ROLES"
        value = "CEO, CTO, CISO, CMMI, Architect, Project Manager, DevOps Engineer, Technical Architect, Software Engineer, QA Engineer, Security Engineer, Business Analyst, UX Designer, UI Designer, Frontend Developer, Backend Developer"
      }

      env {
        name  = "REACT_APP_LOCATIONS"
        value = "India, LATAM, USA"
      }

      env {
        name  = "REACT_APP_EXPIRIENCE"
        value = "0-2 years, 2-5 years, 5-10 years, 10+ years"
      }

      env {
        name  = "REACT_APP_SKILLS"
        value = "Python, Android, Java, Kotlin, Flutter, iOS, Swift, React Native, C++, HTML, CSS, Javascript, React, NodeJS, PHP, Angular, MySQL, Oracle, MongoDB,MS SQL, NoSQL, Networking Protocols, Routing, Network, Cloud, Virtualization, Penetration Testing, Vulnerability Assessment, Tableau, Risk Assessment, Planning, Amazon Web Services, AWS, Microsoft Azure, Google Cloud, Terraform, Ansible, Kubernetes, Grafana, Prometheus, Manual Testing, Automation Testing, Business Analyst, Procurement, Software Licenses, Vendor Relationship"
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

  depends_on = [azurerm_container_app_environment.main, azurerm_container_app.backend_containerapp]
}

output "frontend_containerapp_url" {
  value = azurerm_container_app.frontend_containerapp.ingress[0].fqdn
}