# ========================================
# Backend Storage Account (Separate RG)
# ========================================
# This creates a dedicated storage account for backend services
# in a separate resource group from the main infrastructure

# Create separate resource group for backend storage
resource "azurerm_resource_group" "backend_rg" {
  name     = var.backend_storage_rg_name
  location = var.azure_region

  tags = merge(
    var.tags,
    {
      Name        = var.backend_storage_rg_name
      Environment = var.environment
      Purpose     = "Backend Storage"
    }
  )
}

# Create storage account for backend
resource "azurerm_storage_account" "backend_storage" {
  name                     = var.backend_storage_account_name
  resource_group_name      = azurerm_resource_group.backend_rg.name
  location                 = azurerm_resource_group.backend_rg.location
  account_tier             = "Standard"
  account_replication_type = var.backend_storage_replication_type

  tags = merge(
    var.tags,
    {
      Name        = var.backend_storage_account_name
      Environment = var.environment
      Purpose     = "Backend Data Storage"
    }
  )
}

# Create container for backend data
resource "azurerm_storage_container" "backend_container" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.backend_storage.name
  container_access_type = "private"
}

# Create additional backend containers as needed
resource "azurerm_storage_container" "backend_logs" {
  name                  = "${var.backend_container_name}-logs"
  storage_account_name  = azurerm_storage_account.backend_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backend_uploads" {
  name                  = "${var.backend_container_name}-uploads"
  storage_account_name  = azurerm_storage_account.backend_storage.name
  container_access_type = "private"
}

# Storage account network rules (for security)
resource "azurerm_storage_account_network_rules" "backend_network" {
  storage_account_id         = azurerm_storage_account.backend_storage.id
  default_action             = "Allow"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [module.pcam_networking.aks_subnet_id]
}

# Create storage account access key (for backend services)
resource "azurerm_storage_account_sas" "backend_sas" {
  storage_account_name = azurerm_storage_account.backend_storage.name

  signed_version        = "2021-06-08"
  signed_services       = "b"         # blob
  signed_resource_types = "sco"       # service, container, object
  signed_permissions    = "racwd"     # read, add, create, write, delete

  start  = timeadd(timestamp(), "-1h")
  expiry = timeadd(timestamp(), "8760h") # 1 year
}

# Outputs
output "backend_storage_account_name" {
  value       = azurerm_storage_account.backend_storage.name
  description = "Name of the backend storage account"
}

output "backend_storage_account_id" {
  value       = azurerm_storage_account.backend_storage.id
  description = "ID of the backend storage account"
}

output "backend_resource_group_name" {
  value       = azurerm_resource_group.backend_rg.name
  description = "Name of the backend resource group"
}

output "backend_container_name" {
  value       = azurerm_storage_container.backend_container.name
  description = "Name of the backend container"
}

output "backend_storage_account_key" {
  value       = azurerm_storage_account.backend_storage.primary_access_key
  sensitive   = true
  description = "Primary access key for backend storage account"
}

output "backend_storage_connection_string" {
  value       = azurerm_storage_account.backend_storage.primary_blob_connection_string
  sensitive   = true
  description = "Connection string for backend storage account"
}
