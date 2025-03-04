output "backend_containerapp_url" {
  value = azurerm_container_app.backend_containerapp["benoenv"].ingress[0].fqdn
}

output "frontend_containerapp_url" {
  value = azurerm_container_app.frontend_containerapp.ingress[0].fqdn
}
