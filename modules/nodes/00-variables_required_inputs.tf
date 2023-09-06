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
  type        = string
  description = "The CRI to use for this node."
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of all possible subnets IDS controllers and nodes may be created into"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "The list of all possible subnets CIDR controllers and nodes may be created into"
}

variable "nodes_config_bundle" {
  type = object({
    environment             = string
    k8s_deb_package_version = string
    kubernetes_cluster      = string
    unique_identifier       = string
    controllers_sg_id       = string
    secret_arn              = string
    lb_dns                  = string
  })
  description = "Map which containes all the data requires to spin up and attach a node to a set of controllers. It is an output of the controller module."
}
