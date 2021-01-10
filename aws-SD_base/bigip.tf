terraform {
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
      version = "1.4.0"
    }
  }
}
provider "bigip" {
  address  = "https://${var.address}:${var.port}"
  username = var.username
  password = var.password
}


# Creat Dummy VS to get the virtual address in the common partition.
# This is necessary to be able to use the address in different AS3 tenants
resource "bigip_ltm_virtual_server" "dummy" {
  name          = "/Common/dummy_vs"
  destination   = "10.0.0.200"
  port          = 80
  vlans         = []
  vlans_enabled = true
}



# Generate AS3 JSON
data "template_file" "nginx_json" {
  template = file("templates/nginx.tpl")
  vars = {
    tenant          = var.app_name
    virtual_port    = var.app_port
    virtual_address = "10.0.0.200"
    tag_value       = "${var.prefix}-${var.app_name}"
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
    region                = var.region
  }
}

# deploy application using as3
resource "bigip_as3" "nginx" {
  as3_json    = data.template_file.nginx_json.rendered
  depends_on  = [aws_autoscaling_group.nginx, bigip_ltm_virtual_server.dummy]
}