module bigip {
  count                  = 1
#  source                 = "../../terraform-aws-bigip-module"
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
