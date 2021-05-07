variable "k8s_version" {
  default = "1.20"
}

variable "k8s_full_version" {
  default = "1.20.5"
}

module "docker_cri" {
  source = "../modules/cri/docker"
}

module "containerd_cri" {
  source = "../modules/cri/containerd"
}

module "crio_cri" {
  source = "../modules/cri/cri-o"
}

module "k8s" {
  source                            = "../modules/controllers"
  vpc_id                            = "vpc-xxx" # 10.0.0.0/16
  k8s_controllers_num_nodes         = "1"
  k8s_deb_package_version           = var.k8s_full_version
  kubeadm_install_version           = "stable-${var.k8s_version}"
  controller_join_token             = "xxx.xxx"
  environment                       = "dev"
  unique_identifier                 = "k8s"
  ec2_k8s_controllers_instance_type = "m5a.large"
  kubernetes_cluster                = "k8s-poc"
  internal_network_cidr             = "10.244.0.0/16" # Flannel CIDR
  controllers_cri_bootstrap         = module.docker_cri.cri_bootstrap

  subnets_public_cidr_block = [
    "x.x.x.x/25",
    "x.x.x.x/25",
  ]

  subnets_private_cidr_block = [
    "x.x.x.x/25",
    "x.x.x.x/25",
  ]
}

module "k8s_nodes_containerd" {
  source                        = "../modules/nodes"
  k8s_workers_num_nodes         = "1"
  ec2_k8s_workers_instance_type = "m5a.large"
  vpc_id                        = "vpc-xxx"
  private_subnets               = module.k8s.nodes_subnets_private_id
  nodes_cri_bootstrap           = module.containerd_cri.cri_bootstrap
  nodes_config_bundle           = module.k8s.nodes_config_bundle # You get you configurations from the master module
}

module "k8s_nodes_crio" {
  source                        = "../modules/nodes"
  k8s_workers_num_nodes         = "1"
  ec2_k8s_workers_instance_type = "m5a.large"
  vpc_id                        = "vpc-xxx"
  private_subnets               = module.k8s.nodes_subnets_private_id
  nodes_cri_bootstrap           = module.crio_cri.cri_bootstrap
  nodes_config_bundle           = module.k8s.nodes_config_bundle # You get you configurations from the master module
}

resource "aws_route" "private_subnets_route_traffic_to_NAT" {
  route_table_id         = module.k8s.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.id # NAT Gateway
}

resource "aws_route" "private_subnets_route_traffic_to_IGW" {
  route_table_id         = module.k8s.public_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "xxx"
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = "xxx"
}
