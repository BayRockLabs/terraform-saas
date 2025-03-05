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
