#!/bin/bash
cp ../infrastructure_tf/bigip.tfvars.tmp bigip.auto.tfvars
cp ../infrastructure_tf/aws.tfvars.tmp aws.auto.tfvars

terraform init
#terraform apply -auto-approve

