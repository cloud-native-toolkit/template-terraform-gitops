module "dev_tools_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-k8s-namespace.git"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.namespace
}

module "gitea" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitea"

  cluster_config_file = module.dev_cluster.config_file_path
  ca_cert             = module.dev_cluster.ca_cert
  olm_namespace       = module.dev_software_olm.olm_namespace
  operator_namespace  = module.dev_software_olm.target_namespace
  instance_namespace  = module.dev_tools_namespace.name
}

module "gitops" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops.git"

  gitea_host = module.gitea.host
  gitea_org = module.gitea.org
  gitea_username = module.gitea.username
  gitea_token = module.gitea.token
  repo = var.git_repo
  public = true
  gitops_namespace = var.gitops_namespace
  sealed_secrets_cert = module.cert.cert
}

resource null_resource gitops_output {
  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_repo}' > git_repo"
  }

  provisioner "local-exec" {
    command = "echo -n '${module.gitops.config_token}' > git_token"
  }
}
