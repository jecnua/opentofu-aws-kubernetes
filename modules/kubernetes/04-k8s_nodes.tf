data "template_file" "bootstrap_node_k8s_workers" {
  template = file("${path.module}/scripts/bootstrap.sh")

  vars = {
    controller_join_token   = var.controller_join_token
    is_worker               = "true"
    cluster_id              = var.kubernetes_cluster
    k8s_deb_package_version = var.k8s_deb_package_version
    kubeadm_install_version = "" # Ignored for nodes
    //    load_balancer_dns       = "" # Ignored for nodes
    pre_install         = var.userdata_pre_install
    cni_install         = "" # Ignored for nodes
    post_install        = var.userdata_post_install
    kubeadm_config      = ""
    kubeadm_join_config = data.template_file.bootstrap_k8s_controllers_kubeadm_join_config.rendered
  }
}

resource "aws_launch_configuration" "k8s_workers_launch_configuration" {
  count                       = signum(var.k8s_workers_num_nodes)
  image_id                    = var.ami_id_worker != "" ? var.ami_id_worker : data.aws_ami.ami_dynamic.id
  instance_type               = var.ec2_k8s_workers_instance_type
  key_name                    = var.enable_ssm_access_to_nodes ? null : var.ec2_key_name
  user_data                   = data.template_file.bootstrap_node_k8s_workers.rendered
  iam_instance_profile        = aws_iam_instance_profile.k8s_instance_profile.id
  associate_public_ip_address = false
  enable_monitoring           = false
  ebs_optimized               = false

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.k8s_controllers_instance_root_device_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    aws_security_group.k8s_workers_node_sg.id,
  ]
}

# TODO: access_logs
resource "aws_elb" "k8s_workers_internal_elb" {
  count                     = signum(var.k8s_workers_num_nodes)
  name                      = "${var.unique_identifier}-${var.environment}-wrkr-int-elb"
  subnets                   = aws_subnet.k8s_private.*.id
  idle_timeout              = var.k8s_workers_lb_timeout_seconds
  internal                  = true
  cross_zone_load_balancing = true
  connection_draining       = true

  listener {
    instance_port     = 6443
    instance_protocol = "http"
    lb_port           = 6443
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3 #90 seconds
    timeout             = 10
    target              = "TCP:22"
    interval            = 15
  }

  security_groups = [
    aws_security_group.k8s_workers_internal_elb_ag_sg.id,
  ]

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} workers internal elb"
    KubernetesCluster = var.kubernetes_cluster
  }
}

resource "aws_security_group" "k8s_workers_internal_elb_ag_sg" {
  name        = "kubernetes-node-${var.kubernetes_cluster}"
  vpc_id      = data.aws_vpc.targeted_vpc.id
  description = "Security group for nodes"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} workers internal elb sg"
    KubernetesCluster = var.kubernetes_cluster
  }
}

resource "aws_security_group" "k8s_workers_node_sg" {
  vpc_id = data.aws_vpc.targeted_vpc.id

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} workers sg"
    KubernetesCluster = var.kubernetes_cluster
  }
}

# Allow egress
resource "aws_security_group_rule" "allow_all_egress_from_k8s_worker_nodes" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_workers_node_sg.id
  type              = "egress"
}

# FIXME: THIS NEED TO BE INJECTABLE BUT NOT HERE
resource "aws_security_group_rule" "allow_all_from_us_workers" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internal_network_cidr]
  security_group_id = aws_security_group.k8s_workers_node_sg.id
  type              = "ingress"
}

# Allow ALL connection from other workers
resource "aws_security_group_rule" "allow_all_from_self_workers" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.k8s_workers_node_sg.id
  type              = "ingress"
}

# Allow TCP connections from the ELB
resource "aws_security_group_rule" "allow_all_from_k8s_workers_internal_elb" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_workers_internal_elb_ag_sg.id
  security_group_id        = aws_security_group.k8s_workers_node_sg.id
  type                     = "ingress"
}

# Allow ALL from the cluster: TCP and UDP
# Needed by some CNI network plugins
resource "aws_security_group_rule" "allow_all_from_k8s_controller_nodes" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.k8s_controllers_node_sg.id
  security_group_id        = aws_security_group.k8s_workers_node_sg.id
  type                     = "ingress"
}

resource "aws_autoscaling_group" "k8s_workers_ag" {
  count                     = signum(var.k8s_workers_num_nodes)
  depends_on                = [aws_autoscaling_group.k8s_controllers_ag]
  max_size                  = var.k8s_workers_num_nodes
  min_size                  = var.k8s_workers_num_nodes
  desired_capacity          = var.k8s_workers_num_nodes
  launch_configuration      = aws_launch_configuration.k8s_workers_launch_configuration[0].id
  health_check_grace_period = 300   ## TODO: Parametrise
  health_check_type         = "EC2" ## TODO: What do we want to do with this?
  force_delete              = false
  metrics_granularity       = "1Minute"
  wait_for_capacity_timeout = "10m"
  vpc_zone_identifier       = aws_subnet.k8s_private.*.id
  load_balancers = compact(
    concat(
      [aws_elb.k8s_workers_internal_elb[0].name],
      var.k8s_worker_additional_lbs,
    ),
  )

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

  tag {
    key                 = "Name"
    value               = "${var.unique_identifier} ${var.environment} workers in autoscaling"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "KubernetesCluster"
    value               = var.kubernetes_cluster
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/role/node" # Taken from the kops
    value               = "1"
    propagate_at_launch = true
  }
}
