# Crée le NSG
resource "azurerm_network_security_group" "main" {
  name                = "vm-nsg-tp2"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags  
}

# Autorise seulement SSH depuis ton IP publique
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_public_ip
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Associe le NSG à la carte réseau de la VM
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}
