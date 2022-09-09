resource "aws_secretsmanager_secret" "token" {
  name = "kubernetes-controller-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}-token"
}

resource "aws_secretsmanager_secret" "ca_hash" {
  name = "kubernetes-controller-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}-hash"
}
