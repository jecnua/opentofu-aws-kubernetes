module "k8s" {
  source                            = "../modules/kubernetes"
  access_key                        = ""
  secret_key                        = "xxx"
  network_region                    = "us-east-1"
  vpc_id                            = "vpc-xxx" # DEPENDENCY
  ipsec_vgw                         = "xxx"          # TBR
  nat_gateway                       = "xxx"          # TBR
  subnets_cidr_block                = ["x.x.x.x/x", "x.x.x.x/x"]
  subnets_public_cidr_block         = ["x.x.x.x/x", "x.x.x.x/x"]
  k8s_controllers_num_nodes         = "1"            # Always 1
  k8s_workers_num_nodes             = "2"
  controller_join_token             = "xxx.xxx"
  environment                       = "dev"
  unique_identifier                 = "k8s"          # unique_identifier+environment
  ec2_k8s_controllers_instance_type = "m4.large"
  ec2_k8s_workers_instance_type     = "m4.large"
  ec2_key_name                      = "xxx"
  hostname_prefix_k8s_controllers   = "k8s-controller"
  hostname_prefix_k8s_workers       = "k8s-worker"
  kubernetes_cluster                = "k8s-mgmt"
}
