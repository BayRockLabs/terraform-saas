terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
#   backend "azurerm" {
#     # Define remote state configuration if needed
#   }
}

provider "azurerm" {
  features {}
}