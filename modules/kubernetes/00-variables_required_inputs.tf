###################################### Providers

variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "network_region" {
  type = "string"
}

###################################### General

variable "unique_identifier" {
  type = "string"
}

variable "environment" {
  type = "string"
}

variable "controller_join_token" {
  type = "string"
}

variable "kubernetes_cluster" {
  type = "string"
}

###################################### Network

variable "vpc_id" {
  type = "string"
}

variable "nat_gateway" {
  type = "string"
}

variable "subnets_cidr_block" {
  type = "list"
}

variable "subnets_public_cidr_block" {
  type = "list"
}

###################################### EC2

variable "ec2_key_name" {
  type = "string"
}

variable "ec2_k8s_controllers_instance_type" {
  type = "string"
}

variable "ec2_k8s_workers_instance_type" {
  type = "string"
}

variable "k8s_controllers_num_nodes" {
  type = "string"
}

variable "k8s_workers_num_nodes" {
  type = "string"
}

###################################### bootstrap

variable "internet_gateway" {
  type = "string"
}

variable "internal_network_cidr" {
  type = "string"
}
