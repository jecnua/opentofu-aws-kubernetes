# SG of the node itself
resource "aws_security_group" "k8s_controllers_node_sg" {
  vpc_id = data.aws_vpc.targeted_vpc.id
  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} controllers sg"
    KubernetesCluster = var.kubernetes_cluster
  }
}

# Allow egress
resource "aws_security_group_rule" "allow_all_egress_from_k8s_controller_nodes" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
  type              = "egress"
}

# Allow ALL connection from other nodes like me
resource "aws_security_group_rule" "allow_all_from_self_controllers" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
  type              = "ingress"
}
