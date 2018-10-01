
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access_key |  | string | - | yes |
| ami_id_controller | The id of the AMI to use for the controller. If empty, the latest ubuntu will be user. | string | `` | no |
| ami_id_worker | The id of the AMI to use for the workers. If empty, the latest ubuntu will be user. | string | `` | no |
| ami_name_filter_regex | Regex to find the ami to use | string | `ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*` | no |
| ami_name_regex | The name regex | string | `^.*` | no |
| ami_owner | ID of the owner of the ami (example 099720109477 for Canonical) | string | `099720109477` | no |
| availability_zone | r4.2xlarge are still not available in C | list | `<list>` | no |
| controller_join_token |  | string | - | yes |
| ec2_k8s_controllers_instance_root_device_size |  | string | `40` | no |
| ec2_k8s_controllers_instance_type |  | string | - | yes |
| ec2_k8s_workers_instance_root_device_size |  | string | `40` | no |
| ec2_k8s_workers_instance_type |  | string | - | yes |
| ec2_key_name |  | string | - | yes |
| environment |  | string | - | yes |
| hostname_prefix_k8s_controllers |  | string | - | yes |
| hostname_prefix_k8s_workers |  | string | - | yes |
| internal_network_cidr |  | string | - | yes |
| internet_gateway |  | string | - | yes |
| k8s_controllers_elb_timeout |  | string | `60` | no |
| k8s_controllers_num_nodes |  | string | - | yes |
| k8s_worker_additional_elbs | List of additional ELBs to attach to the AG for nodes (workers) | list | `<list>` | no |
| k8s_workers_elb_timeout |  | string | `60` | no |
| k8s_workers_num_nodes |  | string | - | yes |
| kubernetes_cluster |  | string | - | yes |
| nat_gateway |  | string | - | yes |
| network_region |  | string | - | yes |
| secret_key |  | string | - | yes |
| sns_topic_notifications | The SNS topic to use when the system autoscale. If empty no notification will be sent | string | `` | no |
| subnets_cidr_block |  | list | - | yes |
| subnets_public_cidr_block |  | list | - | yes |
| unique_identifier |  | string | - | yes |
| vpc_id |  | string | - | yes |

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
| workers_elb_internal_dns_name | The AWS DNS name of the worker nodes ELB |
| workers_elb_internal_zone_id | The AWS zone id for the worker nodes ELB |

