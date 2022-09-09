resource "random_string" "seed" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

data "template_file" "bootstrap_node_k8s_controllers" {
  template = file("${path.module}/scripts/bootstrap.sh")

  vars = {
    //    cluster_id              = var.kubernetes_cluster
    //    load_balancer_dns       = aws_elb.k8s_controllers_external_elb.dns_name
    controller_join_token   = var.controller_join_token
    k8s_deb_package_version = var.k8s_deb_package_version
    kubeadm_install_version = var.kubeadm_install_version
    pre_install             = var.userdata_pre_install
    cni_install             = var.userdata_cni_install
    post_install            = var.userdata_post_install
    kubeadm_config          = data.template_file.bootstrap_k8s_controllers_kubeadm_config.rendered
    kubeadm_etcd_encryption = data.template_file.bootstrap_k8s_controllers_kubeadm_etcd_encryption.rendered
    cri_installation        = var.controllers_cri_bootstrap
    audit_policy            = data.template_file.bootstrap_audit_config_policy_file_yaml.rendered
    secret_name             = aws_secretsmanager_secret.secrets.name
  }
}

data "template_file" "bootstrap_k8s_controllers_kubeadm_config" {
  template = file("${path.module}/scripts/kubeadm_config.yaml")
  vars = {
    k8s_deb_package_version  = var.k8s_deb_package_version
    controller_join_token    = var.controller_join_token
    enable_admission_plugins = var.enable_admission_plugins
  }
}

data "template_file" "bootstrap_audit_config_policy_file_yaml" {
  template = file("${path.module}/scripts/audit-policy.yaml")
  vars     = {}
}

data "template_file" "bootstrap_k8s_controllers_kubeadm_etcd_encryption" {
  template = file("${path.module}/scripts/etcd_enc.yaml")
  vars     = {}
}

data "template_cloudinit_config" "controller_bootstrap" {
  gzip          = true
  base64_encode = true
  # Main cloud-config configuration file.
  part {
    filename     = "boostrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.bootstrap_node_k8s_controllers.rendered
  }
}

resource "aws_launch_template" "controller" {
  name                                 = "kubernetes-controller-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}"
  instance_initiated_shutdown_behavior = "terminate"
  image_id                             = var.ami_id != "" ? var.ami_id : data.aws_ami.ami_dynamic.id
  instance_type                        = var.ec2_k8s_controllers_instance_type
  user_data                            = data.template_cloudinit_config.controller_bootstrap.rendered
  key_name                             = var.enable_ssm_access_to_nodes ? null : var.ec2_key_name
  tags                                 = local.tags_as_map
  #  vpc_security_group_ids               = [aws_security_group.k8s_controllers_node_sg.id] # Invalid launch template: When a network interface is provided, the security groups must be a part of it.

  dynamic "block_device_mappings" {
    for_each = [var.block_device_mappings]

    content {
      device_name = "/dev/sda1" # root

      ebs {
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true) # cattle not pets
        volume_type           = lookup(block_device_mappings.value, "volume_type", var.ebs_volume_type)
        volume_size           = lookup(block_device_mappings.value, "volume_size", var.ebs_root_volume_size)
        encrypted             = lookup(block_device_mappings.value, "encrypted", true)
        iops                  = lookup(block_device_mappings.value, "iops", null)
      }
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.k8s_instance_profile.id
  }

  //  instance_market_options {
  //    market_type = var.market_options
  //    spot_options {
  //      spot_instance_type = "one-time" # Auto Scaling only supports the 'one-time' Spot instance type with no duration.
  //    }
  //  }

  # Remounting the same private IP when a node dies
  network_interfaces {
    network_interface_id = aws_network_interface.fixed_private_ip.id
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags_as_map
  }
}

resource "aws_network_interface" "fixed_private_ip" {
  subnet_id       = aws_subnet.k8s_private.0.id
  security_groups = [aws_security_group.k8s_controllers_node_sg.id]
}

# TODO: Use this var.k8s_controllers_num_nodes to cycle
resource "aws_autoscaling_group" "k8s_controllers_ag" {
  name                      = "kubernetes-controller-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = false
  metrics_granularity       = "1Minute"
  wait_for_capacity_timeout = "10m"
  availability_zones        = [aws_subnet.k8s_private.0.availability_zone] # TODO: Cycle them up to AZs # Required now that I use a fixed private IP
  #  vpc_zone_identifier       = [aws_subnet.k8s_private.0.id] # A network interface may not specify both a network interface ID and a subnet. Launching EC2 instance failed.

  launch_template {
    id      = aws_launch_template.controller.id
    version = "$Latest"
  }

  load_balancers = [
    aws_elb.k8s_controllers_internal_elb.name,
  ]

  termination_policies = [
    "OldestInstance",
  ]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = local.tags_for_asg
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }
}
