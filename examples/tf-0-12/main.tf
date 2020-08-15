provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.13.0"
}

provider "template" {
  version = "~> 2.1.2"
}

module "k8s" {

  providers = {
    aws      = aws
    template = template
  }

  source                            = "..\/..\/modules\/kubernetes"
  network_region                    = "eu-west-1"
  region                            = "eu-west-1"
  vpc_id                            = "vpc-xxx"
  k8s_controllers_num_nodes         = "1" # Don't change this. This module does not support HA
  k8s_workers_num_nodes             = "1"
  k8s_deb_package_version           = "1.15.0"
  kubeadm_install_version           = "stable-1.15"
  controller_join_token             = "xxx.yyy"
  environment                       = "dev"
  unique_identifier                 = "k8s"
  ec2_k8s_controllers_instance_type = "m5.large"
  ec2_k8s_workers_instance_type     = "m5.large"
  ec2_key_name                      = "xxx"
  kubernetes_cluster                = "k8s-poc"
  internal_network_cidr             = "0.0.0.0/0"

  subnets_public_cidr_block = [
    "xxx.xxx.xxx.0/25",
    "xxx.xxx.xxx.128/25",
  ]

  subnets_private_cidr_block = [
    "xxx.xxx.xxx.0/25",
    "xxx.xxx.xxx.128/25",
  ]
}

resource "aws_route" "private_subnets_route_traffic_to_NAT" {
  route_table_id         = "${module.k8s.private_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "nat-xxx" # NAT Gateway
}

resource "aws_route" "private_subnets_route_traffic_to_IGW" {
  route_table_id         = "${module.k8s.public_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-yyy" # Internet Gateway
}
