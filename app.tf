# Create network interface with static public ip
resource "azurerm_network_interface" "test-app"{
  name                = "test-nic-app"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration{
    name = "test-ip-app"
    subnet_id = "${azurerm_subnet.test-app.id}"
    private_ip_address_allocation = "Dynamic"
  }

}

# Create LB
resource "azurerm_lb" "test-app" {
  name = "app-lb"
  location = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  
  frontend_ip_configuration {
    name = "app-ip-config"
    #public_ip_address_id = "${azurerm_public_ip.test-app.id}"
  }
}

# Create LB backend address pool
resource "azurerm_lb_backend_address_pool" "test-app" {
  name = "app-backend-pool"
  loadbalancer_id = "${azurerm_lb.test-app.id}"
}

# Create LB Probe
resource "azurerm_lb_probe" "test-app" {
  name = "app-lb-probe"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id = "${azurerm_lb.test-app.id}"
  protocol = "Tcp"
  port = "8001"
  interval_in_seconds = "5"
  number_of_probes = "2"
}

# Create LB rule
resource "azurerm_lb_rule" "test-app" {
  name = "app-lb-rule"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id = "${azurerm_lb.test-app.id}"
  frontend_ip_configuration_name = "${azurerm_lb.test-app.frontend_ip_configuration[0].name}"
  protocol = "Tcp"
  frontend_port = "80"
  backend_port = "80"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.test-app.id}"
  probe_id = "${azurerm_lb_probe.test-app.id}"
}

# Create Static public ip
#resource "azurerm_public_ip" "test-app" {
#  name                = "app-public-ip"
#  location            = "${azurerm_resource_group.test.location}"
#  resource_group_name = "${azurerm_resource_group.test.name}"
#  allocation_method   = "Static"
#}

# Create VM1
resource "azurerm_virtual_machine" "test-app"{
  name = "test-vm-app"
  location = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test-app.id}"]
  vm_size = "Standard_A0"

  storage_image_reference{
  publisher = "RedHat"
  offer = "RHEL"
  sku = "7-RAW"
  version = "latest" 
  }
  
  storage_os_disk {
    name              = "disk1-app"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "terraform-app"
    admin_username = "admin"
    admin_password = "Welcome@1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
 
}