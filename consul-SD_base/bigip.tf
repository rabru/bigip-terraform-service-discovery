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


# Generate AS3 JSON
data "template_file" "nginx_json" {
  template = file("templates/nginx.tpl")
  vars = {
    tenant          = var.app_name,
    virtual_port    = var.app_port,
    virtual_address = var.internal_address
  }
}


# deploy application using as3
resource "bigip_as3" "nginx" {
  as3_json    = data.template_file.nginx_json.rendered
  depends_on  = [aws_autoscaling_group.nginx]
}
