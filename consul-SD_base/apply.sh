#!/bin/bash
cp $1/bigip.tfvars.tmp bigip.auto.tfvars
cp $1/aws.tfvars.tmp aws.auto.tfvars

terraform init
#terraform apply -auto-approve

