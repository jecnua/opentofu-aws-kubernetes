# Will store a fresh token and the CA hash - known only at runtime
# TODO: Remove controller
resource "aws_secretsmanager_secret" "secrets" {
  name = "k8s-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}-secrets"
}
