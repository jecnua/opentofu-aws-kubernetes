variable "vpc_id" {
  type        = string
  description = "The VPC id"
}

variable "ec2_k8s_workers_instance_type" {
  type        = string
  description = "Instance size for the nodes"
}

variable "k8s_workers_num_nodes" {
  type        = string
  description = "Number of nodes for the asg for the nodes"
}

variable "nodes_cri_bootstrap" {
  type = string
}

variable "private_subnets" {}

variable "nodes_config_bundle" {
  type = object({
    environment             = string
    k8s_deb_package_version = string
    kubernetes_cluster      = string
    controller_join_token   = string
    unique_identifier       = string
    controllers_sg_id       = string
    internal_network_cidr   = string
    secret_name             = string
    secret_arn              = string
  })
}
