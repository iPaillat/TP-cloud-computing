# Configure the outputs to display important information after deployment

output "vm_public_ip" {
  description = "L'adresse IP publique de la VM"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_dns_name" {
  description = "Le nom DNS complet de la VM"
  value       = azurerm_public_ip.main.fqdn
}
