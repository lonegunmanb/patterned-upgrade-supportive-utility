data "azurerm_network_interface" "example" {
  name                = "acctest-nic"
  resource_group_name = "networking"
}

locals {
  data_azure_network_interface_enable_accelerated_networking = data.azurerm_network_interface.example.accelerated_networking_enabled
  data_azure_network_interface_enable_ip_forwarding          = data.azurerm_network_interface.example.ip_forwarding_enabled
}