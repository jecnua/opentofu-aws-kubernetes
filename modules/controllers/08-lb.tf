# External LB to connect to the api and have HA
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
# We cannot use an ALB because the connection to the nodes is via SSL and the certs are managed by the control plane
# A more feasible approach is a LAYER4 with TSL pass through
resource "aws_lb" "k8s_controllers_external_lb" {
  name                       = substr("k8s-ctrl-ext-lb-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}", 0, 31)
  subnets                    = aws_subnet.k8s_public.*.id
  idle_timeout               = var.k8s_controllers_lb_timeout_seconds
  internal                   = false
  load_balancer_type         = "network"
  enable_deletion_protection = false

  #  access_logs {
  #    bucket  = aws_s3_bucket.lb_logs.bucket
  #    prefix  = "test-lb"
  #    enabled = true
  #  }

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https:github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} controllers external lb"
    KubernetesCluster = var.kubernetes_cluster
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.k8s_controllers_external_lb.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controllers.arn
  }
}

resource "aws_lb_target_group" "controllers" {
  name     = substr("k8s-ctrl-ext-lb-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}", 0, 31)
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id
}
