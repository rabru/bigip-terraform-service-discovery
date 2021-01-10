# Generate a tfvars file for AS3 installation
data "template_file" "tfvars" {
  template = file("templates/bigip.tfvars.tpl")
  vars = {
    addr     = module.bigip.0.mgmtPublicIP[0]
    port     = "8443"
    username = module.bigip.0.f5_username
    pwd      = module.bigip.0.bigip_password
  }
}
resource "local_file" "tfvars-bigip" {
  content         = data.template_file.tfvars.rendered
  filename        = "bigip.tfvars.tmp"
  file_permission = "0644"
}


# Generate a tfvars file for aws server deployment
data "template_file" "tfvars_aws" {
  template = file("templates/aws.tfvars.tpl")
  vars = {
    prefix                  = var.prefix
    region                  = var.region
    aws_sg_nginx_id         = aws_security_group.nginx.id
    aws_vpc_zone_identifier = module.vpc.public_subnets[0]
    aws_iam_instance_name   = aws_iam_instance_profile.consul.name
    aws_key_name            = aws_key_pair.demo.key_name
  }
}
resource "local_file" "tfvars-aws" {
  content         = data.template_file.tfvars_aws.rendered
  filename        = "aws.tfvars.tmp"
  file_permission = "0644"
}

