#!/bin/bash

terraform destroy -auto-approve

rm aws.auto.tfvars
rm bigip.auto.tfvars

