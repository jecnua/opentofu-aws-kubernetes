variable "access_key" {}

variable "secret_key" {}

variable "network_region" {}

###################################### General

variable "unique_identifier" {}

variable "environment" {}

variable "controller_join_token" {}

variable "kubernetes_cluster" {}

###################################### Network

variable "vpc_id" {}

variable "nat_gateway" {}

variable "subnets_cidr_block" {
  type = "list"
}

variable "subnets_public_cidr_block" {
  type = "list"
}

###################################### EC2

variable "ec2_key_name" {}

variable "ec2_k8s_controllers_instance_type" {}

variable "ec2_k8s_workers_instance_type" {}

variable "k8s_controllers_num_nodes" {}

variable "k8s_workers_num_nodes" {}

###################################### bootstrap

variable "hostname_prefix_k8s_controllers" {}

variable "hostname_prefix_k8s_workers" {}

variable "internet_gateway" {}

variable "internal_network_cidr" {
  
}
