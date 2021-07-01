resource "azurerm_mssql_server" "testdata" {
  name                         = "data-servers"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "${azurerm_resource_group.test.location}"
  version                      = "12.0"
  administrator_login          = "data-admin"
  administrator_login_password = "Welcome@1234"
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "testdata" {
  name           = "data-db"
  server_id      = "${azurerm_mssql_server.testdata.id}"
  max_size_gb    = 4
  sku_name       = "Basic"

}

resource "azurerm_mssql_firewall_rule" "testdata" {
  name             = "FirewallRule"
  server_id        = "${azurerm_mssql_server.testdata.id}"
  start_ip_address = "10.2.0.0"
  end_ip_address   = "10.2.0.255"
}

