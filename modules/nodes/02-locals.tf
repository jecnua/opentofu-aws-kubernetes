locals {
  environment             = var.nodes_config_bundle["environment"]
  k8s_deb_package_version = var.nodes_config_bundle["k8s_deb_package_version"]
  kubernetes_cluster      = var.nodes_config_bundle["kubernetes_cluster"]
  unique_identifier       = var.nodes_config_bundle["unique_identifier"]
  controller_sg_id        = var.nodes_config_bundle["controllers_sg_id"]
  secret_arn              = var.nodes_config_bundle["secret_arn"]
  lb_dns                  = var.nodes_config_bundle["lb_dns"]
  tags_for_asg            = null_resource.tags_as_list_of_maps.*.triggers
  tags_as_map = merge(
    {
      "Name"              = format("k8s-node-%s-%s-%s", local.unique_identifier, local.environment, random_string.seed.result)
      "Environment"       = format("%s", local.environment)
      "k8s.io/role/node"  = "1" # Taken from the kops # TODO: CHECK
      "KubernetesCluster" = local.kubernetes_cluster
      "ManagedBy"         = "opentofu k8s module"
      "ModuleRepository"  = "https://github.com/jecnua/opentofu-aws-kubernetes"
    },
    var.additional_tags_as_map,
  )
}

# This won't work with an output with unknown data. Until I solve this, I am asking for a new variable
# data "aws_subnet" "target" {
#   for_each = toset(var.private_subnets)
#   id       = each.value
# }

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(local.tags_as_map))
  triggers = {
    "key"                 = keys(local.tags_as_map)[count.index]
    "value"               = values(local.tags_as_map)[count.index]
    "propagate_at_launch" = "true"
  }
}
