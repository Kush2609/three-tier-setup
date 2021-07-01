# Create network interface with static public ip
resource "azurerm_network_interface" "test-web"{
  name                = "test-nic-web"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration{
    name = "test-ip-web"
    subnet_id = "${azurerm_subnet.test-web.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${azurerm_public_ip.test-web.id}"   
  }

}

# Create LB
resource "azurerm_lb" "test-web" {
  name = "web-lb"
  location = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  
  frontend_ip_configuration {
    name = "web-ip-config"
    public_ip_address_id = "${azurerm_public_ip.test-web.id}"
  }
}

# Create LB backend address pool
resource "azurerm_lb_backend_address_pool" "test-web" {
  name = "web-backend-pool"
  loadbalancer_id = "${azurerm_lb.test-web.id}"
}

# Create LB Probe
resource "azurerm_lb_probe" "test-web" {
  name = "web-lb-probe"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id = "${azurerm_lb.test-web.id}"
  protocol = "Tcp"
  port = "8001"
  interval_in_seconds = "5"
  number_of_probes = "2"
}

# Create LB rule
resource "azurerm_lb_rule" "test-web" {
  name = "web-lb-rule"
  resource_group_name = "${azurerm_resource_group.test.name}"
  loadbalancer_id = "${azurerm_lb.test-web.id}"
  frontend_ip_configuration_name = "${azurerm_lb.test-web.frontend_ip_configuration[0].name}"
  protocol = "Tcp"
  frontend_port = "8080"
  backend_port = "8080"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.test-web.id}"
  probe_id = "${azurerm_lb_probe.test-web.id}"
}

# Create Static public ip
resource "azurerm_public_ip" "test-web" {
  name                = "web-public-ip"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  allocation_method   = "Static"
}

# Create VM1
resource "azurerm_virtual_machine" "test-web"{
  name = "test-vm-web"
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
    name              = "disk1-web"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "terraform-web"
    admin_username = ""
    admin_password = ""
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
 
}