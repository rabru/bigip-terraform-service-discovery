variable "app_name" {}
variable "app_port" {}

# bigip:
variable "address" {}
variable "port" {}
variable "username" {}
variable "password" {}

# AWS:
variable "prefix" {}
variable "region" {}
variable "aws_sg_nginx_id" {}
variable "aws_vpc_zone_identifier" {}
variable "aws_iam_instance_name" {}
variable "aws_key_name" {}

# AWS Autoscale Group:
variable "aws_asg_desired" {}
variable "aws_asg_max" {}

