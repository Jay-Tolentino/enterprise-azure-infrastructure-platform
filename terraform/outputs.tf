output "vm_public_ip" {
  description = "Public IP address of the Linux VM."
  value       = azurerm_public_ip.linux.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the Linux VM."
  value       = azurerm_network_interface.linux.private_ip_address
}

output "key_vault_name" {
  description = "Azure Key Vault name."
  value       = azurerm_key_vault.main.name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = azurerm_log_analytics_workspace.main.name
}