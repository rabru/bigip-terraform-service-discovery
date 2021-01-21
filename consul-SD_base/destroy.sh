#!/bin/bash

terraform destroy -auto-approve && rm bigip.auto.tfvars && rm aws.auto.tfvars

