# Kubernetes node module

![](https://img.shields.io/badge/ubuntu-20.04-blue.svg)

This module will create a new kubernetes cluster inside your VPC.

# Parameters

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.k8s_workers_ag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_notification.elasticsearch_autoscaling_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_iam_instance_profile.k8s_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.k8s_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.k8s_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_policy_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.k8s_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.k8s_workers_node_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_egress_from_k8s_worker_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_from_k8s_controller_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_from_k8s_worker_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_from_self_workers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.seed](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.ami_dynamic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_vpc.targeted_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [template_file.bootstrap_k8s_controllers_kubeadm_join_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bootstrap_node_k8s_workers](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags_as_map"></a> [additional\_tags\_as\_map](#input\_additional\_tags\_as\_map) | A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws\_autoscaling\_group requires. | `map(string)` | `{}` | no |
| <a name="input_ami_id_worker"></a> [ami\_id\_worker](#input\_ami\_id\_worker) | The id of the AMI to use for the nodes. If empty, the latest ubuntu will be used. | `string` | `""` | no |
| <a name="input_ami_name_filter_regex"></a> [ami\_name\_filter\_regex](#input\_ami\_name\_filter\_regex) | Regex to find the ami to use | `string` | `"ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"` | no |
| <a name="input_ami_name_regex"></a> [ami\_name\_regex](#input\_ami\_name\_regex) | The name regex | `string` | `"^.*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | ID of the owner of the ami (example 099720109477 for Canonical) | `string` | `"099720109477"` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The availability zone to use. Be careful, r4.2xlarge are still not available in C for example | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | The EC2 instance block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops` | `map(string)` | `{}` | no |
| <a name="input_ebs_root_volume_size"></a> [ebs\_root\_volume\_size](#input\_ebs\_root\_volume\_size) | The disk size | `number` | `32` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | The EBS type | `string` | `"gp3"` | no |
| <a name="input_ec2_k8s_workers_instance_type"></a> [ec2\_k8s\_workers\_instance\_type](#input\_ec2\_k8s\_workers\_instance\_type) | Instance size for the nodes | `string` | n/a | yes |
| <a name="input_ec2_key_name"></a> [ec2\_key\_name](#input\_ec2\_key\_name) | The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access | `string` | `""` | no |
| <a name="input_enable_ssm_access_to_nodes"></a> [enable\_ssm\_access\_to\_nodes](#input\_enable\_ssm\_access\_to\_nodes) | If set to true the nodes will register to AWS SSM | `bool` | `true` | no |
| <a name="input_k8s_worker_additional_lbs"></a> [k8s\_worker\_additional\_lbs](#input\_k8s\_worker\_additional\_lbs) | List of additional ELBs to attach to the AG for nodes | `list(string)` | `[]` | no |
| <a name="input_k8s_workers_lb_timeout_seconds"></a> [k8s\_workers\_lb\_timeout\_seconds](#input\_k8s\_workers\_lb\_timeout\_seconds) | lb timeout in second for the nodes | `string` | `"60"` | no |
| <a name="input_k8s_workers_num_nodes"></a> [k8s\_workers\_num\_nodes](#input\_k8s\_workers\_num\_nodes) | Number of nodes for the asg for the nodes | `string` | n/a | yes |
| <a name="input_market_options"></a> [market\_options](#input\_market\_options) | Market options for the instances | `string` | `"spot"` | no |
| <a name="input_nodes_config_bundle"></a> [nodes\_config\_bundle](#input\_nodes\_config\_bundle) | n/a | <pre>object({<br>    environment             = string<br>    k8s_deb_package_version = string<br>    kubernetes_cluster      = string<br>    unique_identifier       = string<br>    controllers_sg_id       = string<br>    secret_arn              = string<br>    lb_dns                  = string<br>  })</pre> | n/a | yes |
| <a name="input_nodes_cri_bootstrap"></a> [nodes\_cri\_bootstrap](#input\_nodes\_cri\_bootstrap) | n/a | `string` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_sns_topic_notifications"></a> [sns\_topic\_notifications](#input\_sns\_topic\_notifications) | The SNS topic to notify when the system autoscale. If empty no notification will be sent | `string` | `""` | no |
| <a name="input_userdata_post_install"></a> [userdata\_post\_install](#input\_userdata\_post\_install) | User-data that will be applied on every node after everything else | `string` | `""` | no |
| <a name="input_userdata_pre_install"></a> [userdata\_pre\_install](#input\_userdata\_pre\_install) | User-data that will be applied before everything else is installed | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes_sd_id"></a> [nodes\_sd\_id](#output\_nodes\_sd\_id) | The id of the nodes sg. Allows injection of rules aws\_security\_group\_rule |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# TODO

- Make it single az
- Possible move to use parts (template_cloudinit_config)
- check kubelet extra args if it's not deprecated
- Install the spot helper for spot nodes
- Use datasource instead of heredoc
- Change ebs partition
- Kill the node if the node cannot connect to the master ip
- Fix CA verification
- Add tags on resources with path to the module they are defined it
- Health check on the asg is done via ELB (check for using ALB)
- Export the information needed to create a target group outside the module
- Rename all workers reference to nodes
- Fix/reduce IAM roles power
- Access logs for lbs
