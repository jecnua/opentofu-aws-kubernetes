# SG of the node itself
resource "aws_security_group" "k8s_controllers_node_sg" {
  vpc_id = data.aws_vpc.targeted_vpc.id
  tags = merge(
    local.tags_as_map,
    { Name = "k8s-ctrl-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}" }
  )
}

# Allow egress
resource "aws_security_group_rule" "allow_all_egress_from_k8s_controller_nodes" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
}

# Allow ALL connection from other controllers
resource "aws_security_group_rule" "allow_all_from_self_controllers" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
}

# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
# Allow health checks from the NLB
resource "aws_security_group_rule" "allow_all_lb" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "TCP"
  cidr_blocks       = var.subnets_public_cidr_block
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
}
