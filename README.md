# F5 BIG-IP Service Discovery webinar

Out of several reason server deployments can be very dynamic:
- Maintenance
- Auto Scale implementations
- Dynamic IP assignments

Therefor it is a good idea to get the server deployment out of the Infrastructure as Code (IaC) definition.
To enable this, F5 add into the declarative AS3 deployment Service Discovery,
which can discover dynamically server based on external data store.
Therefore the server deployments can be maintained independent and dynamic, without interfering into the Code of the Infrastructure.
[Here](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html?highlight=service%20discovery)
you can find the documentation of Service Discovery in AS3.  

The IaC implementation is done over terraform and will be deployed in AWS.

# Architecture

To get an infrastructure for the demo we create a new VPC in which we deploy the following components in a single vlan:
- Single BIG-IP as standalone device
- Consul server 

The components above will be used as shared infrastructure for several application deployments. 
The example application deployments are based on the following elements:
- Ubuntu server with Nginx as web server in an autoscale group 
- AS3 Service Discovery deployment on BIG-IP

# How to use this repo


## Requirements

This demo has been developed on Debian buster.  

- terraform 0.13
- aws cli (including credentials to an AWS account)
- openssl

## Preparations 

- Clone the repository & change working directory to terraform
```
git clone https://github.com/rabru/bigip-terraform-service-discovery
cd bigip-terraform-service-discovery
```

## Deploy Infrastructure

Enter the infrastructure folder:
```
cd infrastructure_tf
```

Modify `terraform.tfvars.example`:
- Add a prefix to identify your resources
- Specify the source IP address you will be connecting from i.e. 192.0.2.10/32
- Specify your preferred AWS region 

Rename `terraform.tfvars.example` to us the specified variables:
```
mv terraform.tfvars.example terraform.tfvars
```

Deployment of the infrastructure:
```
terraform init
terraform plan
terraform apply
```

With `terraform output` you will get again the final output.

After the terraform deployment finished, the BIG-IP still need some additional minutes do get initiated and to install the AS3 rpm packet.
Please have this in mind before you continue with the next steps.

## Deploy AWS Service Discovery application

Here we will discover the server IP based on the EC2 instance tagging in aws. 
[Here](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html?highlight=service%20discovery) 
you can find the related documentation. 

:warning: Be aware that this deployment needs AWS credentials, which I will grep from `~/.aws/credentials`. If you don't like it, please modify it in the `apply.sh` script to your needs.

Copy the folder of the application base definition. This way you can create as many new applications instances as needed.
```
cp -r aws-SD_base aws-app1_tf
cd aws-app1_tf
```

Modify `terraform.tfvars.example`:
- Specify application name to avoid name collisions
- Specify port for the application. Be aware: For this demo I just opened the port range 8080 to 8088.

Rename `terraform.tfvars.example` to us the specified variables:
```
mv terraform.tfvars.example terraform.tfvars
```

To pull all needed variables from the infrastructure start the apply script:
```
./apply.sh
```

This will also include the initiation of terraform. For an automated deployment you could also add the `terraform apply` here, but since this is a demo, I prefere to do it maually. Therefor the next step would be:
```
terraform apply
```


# Product Versions
- Terraform 0.13
- Consul 1.9.0
- BIG-IP image used is 15.1.2 version
- AS3 rpm used is [3.24.0 version](https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm)
- The BIG-IP deployment is done over [terraform AWS BIG-IP Module](https://github.com/f5devcentral/terraform-aws-bigip-module)
