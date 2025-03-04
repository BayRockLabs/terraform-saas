locals {
  combined_env_vars = concat(
    var.env_vars,
    [
      { name = "DB_HOSTNAME", value = "${var.db_server_name}.postgres.database.azure.com" },
      { name = "DB_USERNAME", value = var.db_username },
      { name = "DB_PASSWORD", value = var.db_password },
      { name = "DB_NAME", value = var.db_name },
      { name = "DB_PORT", value = "5432" }
    ]
  )
}
