#!/bin/bash
cp $1/bigip.tfvars.tmp bigip.auto.tfvars
cp $1/aws.tfvars.tmp aws.auto.tfvars

echo "aws_access_key_id = \"`grep aws_access_key_id ~/.aws/credentials | cut -d'=' -f2`\"" >> aws.auto.tfvars
echo "aws_secret_access_key = \"`grep aws_secret_access_key ~/.aws/credentials | cut -d'=' -f2`\"" >> aws.auto.tfvars

terraform init
#terraform apply -auto-approve
