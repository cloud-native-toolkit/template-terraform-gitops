provider "gitops" {
  username = var.git_username
  token = var.git_token
  bin_dir  = module.setup_clis.bin_dir
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}
