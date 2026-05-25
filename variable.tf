# ========================================
# General Variables
# ========================================

variable "azure_region" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project = "backend"
    Owner   = "devops"
  }
}

# ========================================
# Backend Storage Resource Group
# ========================================

variable "backend_storage_rg_name" {
  description = "Name of the resource group for backend storage"
  type        = string
}

# ========================================
# Storage Account Variables
# ========================================

variable "backend_storage_account_name" {
  description = "Name of the backend storage account (must be globally unique)"
  type        = string
}

variable "backend_storage_replication_type" {
  description = "Replication type for storage account (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

# ========================================
# Storage Container Variables
# ========================================

variable "backend_container_name" {
  description = "Name of the primary backend container"
  type        = string
  default     = "backend-data"
}