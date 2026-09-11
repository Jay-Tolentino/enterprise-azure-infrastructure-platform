resource "azurerm_resource_group" "main" {
  name     = "rg-enterprise-azure-dev"
  location = "westus2"

  tags = {
    environment = "dev"
    project     = "enterprise-azure-infrastructure-platform"
    managed_by  = "terraform"
  }
}