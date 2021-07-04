locals {
  layer = "services"
  config_project = var.config_projects[local.layer]
  application_branch = "main"
  config_namespace = "default"
  ingress_host = "dashboard-${var.namespace}.${var.cluster_ingress_hostname}"
  endpoint_url = "http${var.tls_secret_name != "" ? "s" : ""}://${local.ingress_host}"
}

resource null_resource setup_application {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-application.sh '${var.application_repo}' '${var.application_paths[local.layer]}' '${var.namespace}' '${local.values_content}'"

    environment = {
      TOKEN = var.application_token
    }
  }
}

resource null_resource setup_argocd {
  depends_on = [null_resource.setup_application]
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd.sh '${var.config_repo}' '${var.config_paths[local.layer]}' '${local.config_project}' '${var.application_repo}' '${var.application_paths[local.layer]}/dashboard' '${var.namespace}' '${local.application_branch}'"

    environment = {
      TOKEN = var.config_token
    }
  }
}
