# F5 BIG-IP Service Discovery webinar

Out of several reason server deployments can be very dynamic:
- Maintenance
- Auto Scale implementations
- Dynamic IP assignments

Therefore, it is a good idea to get server setup out of the Infrastructure as Code (IaC) definition. With AS3 Service Discovery, F5 enables dynamic server discovery in the declaration and enables an external definition of the pool members setup.
Whis this integration, the server deployments can be maintained independent and dynamic, without interfering into the Code of the Infrastructure.
[Here](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html?highlight=service%20discovery)
you can find the documentation of Service Discovery in AS3.  

In this demo the IaC implementation is done over terraform and will be deployed in AWS.

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
- aws cli (including default credentials setup in ~/.aws/credentials)
- openssl

## Preparations 

- Clone the repository & change working directory to terraform
```
git clone https://github.com/rabru/bigip-terraform-service-discovery
cd bigip-terraform-service-discovery
```

## Deploy Infrastructure

The folder Infrastructure_base we will keep as a resource for new deployments, so that we could create new deployments based on it. To create on new infrastructure, copy the folder and enter the target folder:
```
cp -r infrastructure_base infA_tf
cd infA_tf
```

Modify `terraform.tfvars.example`:
- Add a prefix to identify your resources. If you deploy several infrastructures you should avoid name collisions.
- Specify the source IP address you will be connecting from i.e. 192.0.2.10/32 to limit remote access. You might use `curl ifconfig.co` to get your external IP
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

After the terraform deployment finished, the BIG-IP still need some additional minutes do get initiated and to install the AS3 rpm packet.
Please have this in mind before you continue with the next steps.

With `terraform output` you will get again the final output.
```
$ terraform output
Consul_UI = http://11.22.33.44:8500
F5_IP = 11.22.33.55
F5_Password = 71234e1jrY8WB436
F5_UI = https://11.22.33.55:8443
F5_Username = bigipuser
F5_ssh = ssh -i terraform-20210110163720016600000001.pem admin@11.22.33.55
```

To remove the deployment, please use:
```
terraform destroy
```


## Deploy AWS Service Discovery

Here we will discover the server IP based on the EC2 instance tagging in aws. 
[Here](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html#using-service-discovery-to-automatically-populate-a-pool) 
you can find the related documentation. 

:warning: Be aware that this deployment needs AWS credentials, which will be grepped from `~/.aws/credentials`. If you don't like it, please modify it in the `apply.sh` script to your needs.

Copy the folder of the application base definition. This way you can create as many new applications instances as needed.
```
cp -r aws-SD_base aws-app1_tf
cd aws-app1_tf
```

Modify `terraform.tfvars.example`:
- Specify application name to avoid name collisions
- Specify port for the application. Be aware: In this demo the port range from 8080 to 8088 is available.

Rename `terraform.tfvars.example` to us the specified variables:
```
mv terraform.tfvars.example terraform.tfvars
```

To pull all needed variables from the infrastructure start the apply script. As parameter is the path to the preferred infrastructure needed:
```
./apply.sh ../initA_tf
```

This will also include the initiation of terraform. For an automated deployment you could also add the `terraform apply` here, but since this is a demo, I prefer to do it manually. Therefor the next step would be:
```
terraform apply
```

To remove the deployment, please use:
```
./destroy
```


## Deploy Consul Service Discovery

In this deployment we use Consul for the Service Discovery. We also take the health status under consideration to make sure to integrate only servers in the pool which are up and running. 
[Here](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html#service-discovery-using-hashicorp-consul)
you can find the related documentation.

Copy the folder of the application base definition. This way you can create as many new applications instances as needed.
```
cp -r consul-SD_base consul-app2_tf
cd consul-app2_tf
```

Modify `terraform.tfvars.example`:
- Specify application name to avoid name collisions
- Specify port for the application. Be aware: In this demo the port range from 8080 to 8088 is available.

Rename `terraform.tfvars.example` to us the specified variables:
```
mv terraform.tfvars.example terraform.tfvars
```

To pull all needed variables from the infrastructure start the apply script. As parameter is the path to the preferred infrastructure needed:
```
./apply.sh ../initA_tf
```

This will also include the initiation of terraform. For an automated deployment you could also add the `terraform apply` here, but since this is a demo, I prefer to do it manually. Therefor the next step would be:
```
terraform apply
```

To remove the deployment, please use:
```
./destroy
```


# Product Versions
- Terraform 0.13
- Consul 1.9.0
- BIG-IP image used is 15.1.2 version
- AS3 rpm used is [3.24.0 version](https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.24.0/f5-appsvcs-3.24.0-5.noarch.rpm)
- The BIG-IP deployment is done over [terraform AWS BIG-IP Module](https://github.com/f5devcentral/terraform-aws-bigip-module)
