variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
  default     = "rg-enterprise-azure-dev"
}

variable "resource_group_location" {
  type        = string
  description = "Region containing resource group metadata."
  default     = "westus2"
}

variable "location" {
  type        = string
  description = "Primary Azure workload region."
  default     = "swedencentral"
}

variable "vm_size" {
  type        = string
  description = "Azure VM SKU."
  default     = "Standard_B2als_v2"
}

variable "admin_username" {
  type        = string
  description = "Linux administrator username."
  default     = "azureadmin"
}

variable "ssh_source_cidr" {
  type        = string
  description = "CIDR permitted to SSH into the VM."
  default     = "198.135.224.110/32"
}