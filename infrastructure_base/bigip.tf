module bigip {
  count                  = 1
  source                 = "git::https://github.com/f5devcentral/terraform-aws-bigip-module?ref=0.9"
  prefix                 = "${var.prefix}-bigip"
  ec2_instance_type      = "m5.large"
  ec2_key_name           = aws_key_pair.demo.key_name
  f5_ami_search_name     = var.f5_ami_search_name
  f5_username            = var.f5_username
  mgmt_subnet_ids        = [{ "subnet_id" = module.vpc.public_subnets[0], "public_ip" = true, "private_ip_primary" = "10.0.0.200" }]
  mgmt_securitygroup_ids = [aws_security_group.f5.id]
  AS3_URL                = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm"
}

resource "null_resource" "wait_bigip" {

  # Wait until BIG-IP is ready
  provisioner "local-exec" {
    command = "scripts/wait-f5-ready.sh ${module.bigip.0.f5_username} ${module.bigip.0.bigip_password} ${module.bigip.0.mgmtPublicIP[0]}:8443 >> ${path.module}/bigip.log"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rm ${path.module}/bigip.log"
  }
}

resource "null_resource" "deploy_dummy_vs" {

  # This VS is created to get the virtual address in the common partition.
  # Ony then we can share the same virtual address over several AS3 tenants.
  depends_on = [null_resource.wait_bigip]
  provisioner "local-exec" {
    command = <<-EOF
        #!/bin/bash
        curl -k -X POST https://${module.bigip.0.mgmtPublicIP[0]}:8443/mgmt/tm/ltm/virtual \
             -u ${module.bigip.0.f5_username}:${module.bigip.0.bigip_password} \
             -H "Content-Type: application/json" \
             -d "{\"name\": \"dummy_vs\", \"destination\": \"/Common/10.0.0.200:80\", \"vlansEnabled\": true}"
EOF
  }
}

