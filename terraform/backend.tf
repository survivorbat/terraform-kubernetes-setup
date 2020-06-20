terraform {
  backend "azurerm" {
    resource_group_name  = "Example"
    storage_account_name = "examplestate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
