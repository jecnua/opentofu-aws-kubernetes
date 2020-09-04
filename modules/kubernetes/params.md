## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id\_controller | The id of the AMI to use for the controller. If empty, the latest ubuntu will be user. | `string` | `""` | no |
| ami\_id\_worker | The id of the AMI to use for the workers. If empty, the latest ubuntu will be user. | `string` | `""` | no |
| ami\_name\_filter\_regex | Regex to find the ami to use | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| ami\_name\_regex | The name regex | `string` | `"^.*"` | no |
| ami\_owner | ID of the owner of the ami (example 099720109477 for Canonical) | `string` | `"099720109477"` | no |
| availability\_zone | The availability zone to use. r4.2xlarge are still not available in C | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| controller\_join\_token | kubeadm control join token. This needs to be unique for each cluster | `string` | n/a | yes |
| ec2\_k8s\_controllers\_instance\_type | Instance size for the controllers | `string` | n/a | yes |
| ec2\_k8s\_workers\_instance\_type | Instance size for the nodes | `string` | n/a | yes |
| ec2\_key\_name | The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access | `string` | `""` | no |
| enable\_admission\_plugins | The comma separated list of admission plugin to enable | `string` | `"NodeRestriction"` | no |
| enable\_ssm\_access\_to\_nodes | If set to true the nodes will register to AWS SSM | `bool` | `true` | no |
| environment | The environment to use | `string` | n/a | yes |
| internal\_network\_cidr | TEMPORARY: Allow access from a certain ip range | `string` | n/a | yes |
| k8s\_controllers\_instance\_root\_device\_size | root device size (GB) for the nodes | `string` | `"40"` | no |
| k8s\_controllers\_instance\_root\_device\_size\_seconds | root device size (GB) for the controllers | `string` | `"40"` | no |
| k8s\_controllers\_lb\_timeout\_seconds | lb timeout in seconds for the controllers | `string` | `"60"` | no |
| k8s\_controllers\_num\_nodes | Number of nodes in the asg for the controllers | `string` | n/a | yes |
| k8s\_deb\_package\_version | The version of the deb package to install in ubuntu (i.e. 1.18.2) | `string` | `"1.19.4"` | no |
| k8s\_worker\_additional\_lbs | List of additional ELBs to attach to the AG for nodes (workers) | `list(string)` | `[]` | no |
| k8s\_workers\_lb\_timeout\_seconds | lb timeout in second for the nodes | `string` | `"60"` | no |
| k8s\_workers\_num\_nodes | Number of nodes for the asg for the nodes | `string` | n/a | yes |
| kubeadm\_install\_version | The version to install in the syntax expected by kubeadm (i.e. stable-1.18) | `string` | `"stable-1.19"` | no |
| kubernetes\_cluster | Cluster name indentifier | `string` | n/a | yes |
| network\_region | The AWS region where to spin the infrastructure | `string` | n/a | yes |
| region | The region to use with the aws cli in the bootstrap (region you are spinning k8s in) | `string` | `"us-east-1"` | no |
| sns\_topic\_notifications | The SNS topic to notify when the system autoscale. If empty no notification will be sent | `string` | `""` | no |
| subnets\_private\_cidr\_block | The CIDR to use when creating private subnets | `list(string)` | n/a | yes |
| subnets\_public\_cidr\_block | The CIDR to use when creating public subnets | `list(string)` | n/a | yes |
| unique\_identifier | A UUID to be used in resource names generation to avoid conflicts | `string` | n/a | yes |
| userdata\_cni\_install | User-data script that will be applied only in master | `string` | `"su \"$KCTL_USER\" -c \"kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml\""` | no |
| userdata\_post\_install | User-data that will be applied on every node after everything else | `string` | `""` | no |
| userdata\_pre\_install | User-data that will be applied before everything else is installed | `string` | `""` | no |
| vpc\_id | The VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller\_elb\_internal\_dns\_name | The AWS DNS name of the controller nodes ELB |
| controller\_elb\_internal\_zone\_id | The AWS zone id for the controller nodes ELB |
| controllers\_sd\_id | The id of the controllers sg. Allows injection of rules aws\_security\_group\_rule |
| k8s\_role\_id | The role the nodes use. Can be used to attach policies |
| nodes\_sd\_id | The id of the nodes (workers) sg. Allows injection of rules aws\_security\_group\_rule |
| nodes\_subnets\_private\_id | The nodes subnets id |
| nodes\_subnets\_public\_id | The nodes subnets id |
| private\_route\_table\_id | The id of the PRIVATE route table |
| public\_route\_table\_id | The id of the PUBLIC route table |

