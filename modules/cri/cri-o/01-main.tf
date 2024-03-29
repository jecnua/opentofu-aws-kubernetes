data "template_file" "bootstrap_k8s_cri_installation_docker" {
  template = file("${path.module}/scripts/cri-o.sh")
  vars = {
    kubernetes_version = var.kubernetes_version
  }
}

output "cri_bootstrap" {
  value = data.template_file.bootstrap_k8s_cri_installation_docker.rendered
}
