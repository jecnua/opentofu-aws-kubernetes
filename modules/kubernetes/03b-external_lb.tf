# resource "aws_lb" "k8s_controllers_external_lb" {
#   name                      = "${var.unique_identifier}-${var.environment}-ctrl-ext-lb"
#   subnets                   = aws_subnet.k8s_public.*.id
#   idle_timeout              = var.k8s_controllers_lb_timeout_seconds
#   load_balancer_type        = "application"
#   internal                  = false
#
#   security_groups = [
#     aws_security_group.k8s_controllers_nodes_external_lb.id,
#   ]
#
#   tags = {
#     Environment       = var.environment
#     ManagedBy         = "terraform k8s module"
#     ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
#     Name              = "${var.unique_identifier} ${var.environment} controllers external application lb"
#     KubernetesCluster = var.kubernetes_cluster
#   }
# }
#
# resource "aws_lb_listener" "k8s_controllers_external_lb_listener" {
#   load_balancer_arn = "${aws_lb.k8s_controllers_external_lb.arn}"
#   port              = "6443"
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = "${aws_lb_target_group.k8s_controllers_external_lb_tg.arn}"
#   }
# }
#
# resource "aws_lb_target_group" "k8s_controllers_external_lb_tg" {
#   name     = "${var.unique_identifier}-${var.environment}-ctrl-ext-lb-tg"
#   port     = 6443
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.targeted_vpc.id
# }
#
# resource "aws_autoscaling_attachment" "k8s_controllers_ag" {
#   autoscaling_group_name = "${aws_autoscaling_group.k8s_controllers_ag.id}"
#   alb_target_group_arn   = "${aws_lb_target_group.k8s_controllers_external_lb_tg.arn}"
# }
#
# resource "aws_security_group" "k8s_controllers_nodes_external_lb" {
#   vpc_id = data.aws_vpc.targeted_vpc.id
#
#   tags = {
#     Environment       = var.environment
#     ManagedBy         = "terraform k8s module"
#     ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
#     Name              = "${var.unique_identifier} ${var.environment} controllers sg"
#     KubernetesCluster = var.kubernetes_cluster
#   }
# }
# resource "aws_security_group_rule" "allow_all_from_k8s_controller_external_lb" {
#   from_port                = 0
#   to_port                  = 0
#   protocol                 = "-1"
#   source_security_group_id = aws_security_group.k8s_controllers_nodes_external_lb.id
#   security_group_id        = aws_security_group.k8s_controllers_node_sg.id
#   type                     = "ingress"
# }

