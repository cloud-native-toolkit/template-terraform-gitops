locals {
  name      = "my-module"
  chart_dir = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  ingress_host  = "${local.name}-${var.namespace}.${var.cluster_ingress_hostname}"
  ingress_url   = "https://${local.ingress_host}"
  service_url  = "http://${local.name}.${var.namespace}"
  values_content = {
  }
  layer = "services"
  application_branch = "main"
  layer_config = var.gitops_config[local.layer]
}

resource null_resource setup_chart {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.chart_dir}'"

    environment = {
      VALUES_CONTENT = yamlencode(local.values_content)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.setup_chart]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh '${local.name}' '${local.chart_dir}' '${local.name}' '${local.application_branch}' '${var.namespace}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}
