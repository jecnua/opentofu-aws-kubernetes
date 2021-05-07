resource "random_string" "seed" {
  length  = 6
  lower   = true
  upper   = false
  number  = true
  special = false
}

resource "aws_security_group" "k8s_workers_node_sg" {
  vpc_id = data.aws_vpc.targeted_vpc.id
  tags   = local.tags_as_map
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
  cidr_blocks       = [local.internal_network_cidr]
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

# Allow ALL from the cluster: TCP and UDP
# Needed by some CNI network plugins
resource "aws_security_group_rule" "allow_all_from_k8s_controller_nodes" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = local.controller_sg_id
  security_group_id        = aws_security_group.k8s_workers_node_sg.id
  type                     = "ingress"
}

# Allow everything from the cluster: TCP and UDP
# Needed by some CNI network plugins
# TODO: Fix this???
# You will change the master sg. Find a better way
resource "aws_security_group_rule" "allow_all_from_k8s_worker_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.k8s_workers_node_sg.id
  security_group_id        = local.controller_sg_id
}

resource "aws_autoscaling_notification" "elasticsearch_autoscaling_notification" {
  count     = var.sns_topic_notifications == "" ? 0 : 1
  topic_arn = var.sns_topic_notifications

  group_names = [
    aws_autoscaling_group.k8s_workers_ag[0].name,
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
}
