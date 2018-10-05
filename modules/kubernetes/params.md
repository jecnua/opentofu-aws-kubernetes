
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_id_controller | The id of the AMI to use for the controller. If empty, the latest ubuntu will be user. | string | `` | no |
| ami_id_worker | The id of the AMI to use for the workers. If empty, the latest ubuntu will be user. | string | `` | no |
| ami_name_filter_regex | Regex to find the ami to use | string | `ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*` | no |
| ami_name_regex | The name regex | string | `^.*` | no |
| ami_owner | ID of the owner of the ami (example 099720109477 for Canonical) | string | `099720109477` | no |
| availability_zone | The availability zone to use. r4.2xlarge are still not available in C | list | `<list>` | no |
| controller_join_token | kubeadm control join token. This needs to be unique for each cluster | string | - | yes |
| ec2_k8s_controllers_instance_type | Instance size for the controllers | string | - | yes |
| ec2_k8s_workers_instance_type | Instance size for the nodes | string | - | yes |
| ec2_key_name | The key name to associate to the new ec2 servers | string | - | yes |
| environment | The environment to use | string | - | yes |
| internal_network_cidr | TEMPORARY: Allow access from a certain ip range | string | - | yes |
| k8s_controllers_instance_root_device_size | root device size (GB) for the nodes | string | `40` | no |
| k8s_controllers_instance_root_device_size_seconds | root device size (GB) for the controllers | string | `40` | no |
| k8s_controllers_lb_timeout_seconds | lb timeout in seconds for the controllers | string | `60` | no |
| k8s_controllers_num_nodes | Number of nodes in the asg for the controllers | string | - | yes |
| k8s_worker_additional_lbs | List of additional ELBs to attach to the AG for nodes (workers) | list | `<list>` | no |
| k8s_workers_lb_timeout_seconds | lb timeout in second for the nodes | string | `60` | no |
| k8s_workers_num_nodes | Number of nodes for the asg for the nodes | string | - | yes |
| kubernetes_cluster | Cluster name indentifier | string | - | yes |
| nat_gateway | temp | string | `` | no |
| network_region | The AWS region where to spin the infrastructure | string | - | yes |
| region | The region to use with the aws cli in the bootstrap (region you are spinning k8s in) | list | `us-east-1` | no |
| sns_topic_notifications | The SNS topic to notify when the system autoscale. If empty no notification will be sent | string | `` | no |
| subnets_private_cidr_block | The CIDR to use when creating private subnets | list | - | yes |
| subnets_public_cidr_block | The CIDR to use when creating public subnets | list | - | yes |
| unique_identifier | A UUID to be used in resource names generation to avoid conflicts | string | - | yes |
| vpc_id | The VPC id | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| controller_elb_internal_dns_name | The AWS DNS name of the controller nodes ELB |
| controller_elb_internal_zone_id | The AWS zone id for the controller nodes ELB |
| k8s_role_id | The role the nodes use. Can be used to attach policies |
| nodes_ag_availability_zones | The nodes autoscaling group AZ used |
| nodes_ag_id | The nodes autoscaling group id |
| nodes_sd_id | The id of the nodes (workers) sg. Allows injection of rules aws_security_group_rule |
| nodes_subnets_private_id | The nodes subnets id |
| nodes_subnets_public_id | The nodes subnets id |
| private_route_table_id | The id of the PRIVATE route table |
| public_route_table_id | The id of the PUBLIC route table |
| workers_elb_internal_dns_name | The AWS DNS name of the worker nodes ELB |
| workers_elb_internal_zone_id | The AWS zone id for the worker nodes ELB |

