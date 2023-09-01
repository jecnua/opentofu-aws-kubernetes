resource "random_string" "seed" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
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

# Allow ALL connection from other nodes
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
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = local.controller_sg_id
  security_group_id        = aws_security_group.k8s_workers_node_sg.id
}

# Allow everything from the cluster: TCP and UDP
# Needed by some CNI network plugins
# TODO: Fix this???
# You will change the controller sg. Find a better way
resource "aws_security_group_rule" "allow_all_from_k8s_worker_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.k8s_workers_node_sg.id
  security_group_id        = local.controller_sg_id
}

# https://kubernetes.io/docs/reference/networking/ports-and-protocols/
# When deploying metric server it may go on any worker node and it needs to speak to kubelet on any
# other node. We do not know when we create a node all the sg to add, so we allow all the internal subnets
resource "aws_security_group_rule" "allow_kubelet_port_from_internal_subnets" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "TCP"
  cidr_blocks       = values(data.aws_subnet.target).*.cidr_block
  security_group_id = aws_security_group.k8s_workers_node_sg.id
}