# Will store a fresh token and the CA hash - known only at runtime
# TODO: Remove the cert signing key from node access
# TODO: Remove redundant secret at the end
resource "aws_secretsmanager_secret" "secrets" {
  name        = "k8s-${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}-secrets"
  description = "Secret shared between control plane and nodes for cluster ${var.environment}-${var.kubernetes_cluster}-${random_string.seed.result}"
  tags        = local.tags_as_map
}
