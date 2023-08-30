# Kubernetes controller module

![](https://img.shields.io/badge/ubuntu-22.04-blue.svg)

This module will create a new kubernetes cluster inside your VPC.

## Usage

- [Utilities](../../examples/)

Remember to [generate a kubeadm token](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/#cmd-token-generate):

    kubeadm token generate

Be careful to pass the right subnets in availability_zone!

### Choose the version

You can choose what version of k8s to install passing this variables:

    k8s_deb_package_version           = "1.27.5"
    kubeadm_install_version           = "stable-1.27"

## Debug

To get the kubelet logs:

    journalctl -u kubelet

## Connect to the cluster

You can follow the guide here:

- [Utilities](../../utilities/)

## AMI

The module accepts a parameter.
If nothing is passed, the latest ubuntu will be fetched.
Only ubuntu is supported.

## Notes

The bootstrap file will create a cluster via kubeadm.

    MASTER_IP=`aws ec2 describe-instances --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLUSTER_ID" --region='us-east-1' | grep '\"PrivateIpAddress\"' | cut -d ':' -f2 | cut -d'"' -f 2 | uniq`

I use this line to find MY master (it works also if you have multiple clusters).

    $CLUSTER_ID

Must be unique per cluster.

## Cloud provider

- https://cloud-provider-aws.sigs.k8s.io/getting_started/

## Gotchas

### skip-preflight-checks

While configuring a new node, I was receiving the following error:

    [preflight] Some fatal errors occurred:
    /var/lib/kubelet is not empty

As a temporary fix I added

    --skip-preflight-checks

So now the new join call is:

    kubeadm join \
    --skip-preflight-checks \
    --token=$CONTROLLER_JOIN_TOKEN $MASTER_IP

## kube-bench

- [https://github.com/aquasecurity/kube-bench](https://github.com/aquasecurity/kube-bench)

Running the CIS benchmarks on the controllers still returns 5 FAILURES:

[FAIL] 1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)
[FAIL] 1.1.19 Ensure that the Kubernetes PKI directory and file ownership is set to root:root (Automated)
[FAIL] 1.2.6 Ensure that the --kubelet-certificate-authority argument is set as appropriate (Automated)
[FAIL] 1.2.16 Ensure that the admission control plugin PodSecurityPolicy is set (Automated)
[FAIL] 1.3.6 Ensure that the RotateKubeletServerCertificate argument is set to true (Automated)

About the following:

- 1.1.12: kubeadm doesn't manage an ETCD user on the machine, just root. So there is nothing to change there.
- 1.1.19: The directory IS owned by root. I really don't understand why it complains.

More [here](result.txt)

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
| [aws_autoscaling_group.k8s_controllers_ag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_notification.elasticsearch_autoscaling_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_iam_instance_profile.k8s_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.k8s_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.k8s_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_policy_att](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb.k8s_controllers_external_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.controllers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_network_interface.fixed_private_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route_table.k8s_private_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.k8s_public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.k8s_private_route_table_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.k8s_public_route_table_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_security_group.k8s_controllers_node_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_egress_from_k8s_controller_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_from_self_controllers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_all_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.k8s_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.k8s_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.seed](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_ami.ami_dynamic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_vpc.targeted_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [template_cloudinit_config.controller_bootstrap](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.bootstrap_audit_config_policy_file_yaml](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bootstrap_k8s_controllers_kubeadm_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bootstrap_k8s_controllers_kubeadm_etcd_encryption](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bootstrap_k8s_controllers_kubeadm_join_config](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.bootstrap_node_k8s_controllers](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags_as_map"></a> [additional\_tags\_as\_map](#input\_additional\_tags\_as\_map) | A map of tags and values in the same format as other resources accept. This will be converted into the non-standard format that the aws\_autoscaling\_group requires. | `map(string)` | `{}` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The id of the AMI to use. If empty, the latest ubuntu will be used. | `string` | `""` | no |
| <a name="input_ami_name_filter_regex"></a> [ami\_name\_filter\_regex](#input\_ami\_name\_filter\_regex) | Regex to find the ami to use | `string` | `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"` | no |
| <a name="input_ami_name_regex"></a> [ami\_name\_regex](#input\_ami\_name\_regex) | The name regex | `string` | `"^.*"` | no |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | ID of the owner of the ami (example 099720109477 for Canonical) | `string` | `"099720109477"` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The availability zone to use. Be careful, r4.2xlarge are still not available in C for example | `list(string)` | <pre>[<br>  "eu-west-1a",<br>  "eu-west-1b",<br>  "eu-west-1c"<br>]</pre> | no |
| <a name="input_block_device_mappings"></a> [block\_device\_mappings](#input\_block\_device\_mappings) | The EC2 instance block device configuration. Takes the following keys: `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops` | `map(string)` | `{}` | no |
| <a name="input_controller_join_token"></a> [controller\_join\_token](#input\_controller\_join\_token) | kubeadm control join token. This needs to be unique for each cluster | `string` | n/a | yes |
| <a name="input_controllers_cri_bootstrap"></a> [controllers\_cri\_bootstrap](#input\_controllers\_cri\_bootstrap) | n/a | `string` | n/a | yes |
| <a name="input_ebs_root_volume_size"></a> [ebs\_root\_volume\_size](#input\_ebs\_root\_volume\_size) | The disk size | `number` | `32` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | The EBS type | `string` | `"gp3"` | no |
| <a name="input_ec2_k8s_controllers_instance_type"></a> [ec2\_k8s\_controllers\_instance\_type](#input\_ec2\_k8s\_controllers\_instance\_type) | Instance size for the nodes | `string` | n/a | yes |
| <a name="input_ec2_key_name"></a> [ec2\_key\_name](#input\_ec2\_key\_name) | The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access | `string` | `""` | no |
| <a name="input_enable_admission_plugins"></a> [enable\_admission\_plugins](#input\_enable\_admission\_plugins) | The comma separated list of admission plugin to enable | `string` | `"NodeRestriction"` | no |
| <a name="input_enable_ssm_access_to_nodes"></a> [enable\_ssm\_access\_to\_nodes](#input\_enable\_ssm\_access\_to\_nodes) | If set to true the nodes will register to AWS SSM | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment to use | `string` | n/a | yes |
| <a name="input_k8s_controllers_lb_timeout_seconds"></a> [k8s\_controllers\_lb\_timeout\_seconds](#input\_k8s\_controllers\_lb\_timeout\_seconds) | lb timeout in seconds for the controllers | `string` | `"60"` | no |
| <a name="input_k8s_controllers_num_nodes"></a> [k8s\_controllers\_num\_nodes](#input\_k8s\_controllers\_num\_nodes) | Number of nodes in the asg for the controllers | `string` | n/a | yes |
| <a name="input_k8s_deb_package_version"></a> [k8s\_deb\_package\_version](#input\_k8s\_deb\_package\_version) | The version of the deb package to install in ubuntu (i.e. 1.25.0) | `string` | `"1.25.1"` | no |
| <a name="input_kubeadm_install_version"></a> [kubeadm\_install\_version](#input\_kubeadm\_install\_version) | The version to install in the syntax expected by kubeadm (i.e. stable-1.25) | `string` | `"stable-1.25"` | no |
| <a name="input_kubernetes_cluster"></a> [kubernetes\_cluster](#input\_kubernetes\_cluster) | Cluster name indentifier | `string` | n/a | yes |
| <a name="input_sns_topic_notifications"></a> [sns\_topic\_notifications](#input\_sns\_topic\_notifications) | The SNS topic to notify when the system autoscale. If empty no notification will be sent | `string` | `""` | no |
| <a name="input_subnets_private_cidr_block"></a> [subnets\_private\_cidr\_block](#input\_subnets\_private\_cidr\_block) | The CIDR to use when creating private subnets | `list(string)` | n/a | yes |
| <a name="input_subnets_public_cidr_block"></a> [subnets\_public\_cidr\_block](#input\_subnets\_public\_cidr\_block) | The CIDR to use when creating public subnets | `list(string)` | n/a | yes |
| <a name="input_unique_identifier"></a> [unique\_identifier](#input\_unique\_identifier) | A UUID to be used in resource names generation to avoid conflicts | `string` | n/a | yes |
| <a name="input_userdata_cni_install"></a> [userdata\_cni\_install](#input\_userdata\_cni\_install) | User-data script that will be applied | `string` | `"su \"$KCTL_USER\" -c \"kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml\""` | no |
| <a name="input_userdata_post_install"></a> [userdata\_post\_install](#input\_userdata\_post\_install) | User-data that will be applied on every node after everything else | `string` | `""` | no |
| <a name="input_userdata_pre_install"></a> [userdata\_pre\_install](#input\_userdata\_pre\_install) | User-data that will be applied before everything else is installed | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controller_join_token"></a> [controller\_join\_token](#output\_controller\_join\_token) | n/a |
| <a name="output_controller_lb_internal_dns_name"></a> [controller\_lb\_internal\_dns\_name](#output\_controller\_lb\_internal\_dns\_name) | The AWS DNS name of the controller nodes ELB |
| <a name="output_controller_lb_internal_zone_id"></a> [controller\_lb\_internal\_zone\_id](#output\_controller\_lb\_internal\_zone\_id) | The AWS zone id for the controller nodes ELB |
| <a name="output_k8s_controllers_node_sg_id"></a> [k8s\_controllers\_node\_sg\_id](#output\_k8s\_controllers\_node\_sg\_id) | n/a |
| <a name="output_k8s_deb_package_version"></a> [k8s\_deb\_package\_version](#output\_k8s\_deb\_package\_version) | n/a |
| <a name="output_k8s_role_id"></a> [k8s\_role\_id](#output\_k8s\_role\_id) | The role the nodes use. Can be used to attach policies |
| <a name="output_kubernetes_cluster"></a> [kubernetes\_cluster](#output\_kubernetes\_cluster) | n/a |
| <a name="output_nodes_config_bundle"></a> [nodes\_config\_bundle](#output\_nodes\_config\_bundle) | n/a |
| <a name="output_nodes_subnets_private_id"></a> [nodes\_subnets\_private\_id](#output\_nodes\_subnets\_private\_id) | The nodes subnets id |
| <a name="output_nodes_subnets_public_id"></a> [nodes\_subnets\_public\_id](#output\_nodes\_subnets\_public\_id) | The nodes subnets id |
| <a name="output_private_route_table_id"></a> [private\_route\_table\_id](#output\_private\_route\_table\_id) | The id of the PRIVATE route table |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | The id of the PUBLIC route table |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | n/a |
| <a name="output_unique_identifier"></a> [unique\_identifier](#output\_unique\_identifier) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

# TODO
