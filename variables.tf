
variable "config_repo" {
  type        = string
  description = "The repo that contains the argocd configuration"
}

variable "config_token" {
  type        = string
  description = "The token for the config repo"
}

variable "config_paths" {
  description = "The paths in the config repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "config_projects" {
  description = "The ArgoCD projects in the config repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "application_repo" {
  type        = string
  description = "The repo that contains the application configuration"
}

variable "application_token" {
  type        = string
  description = "The token for the application repo"
}

variable "application_paths" {
  description = "The paths in the application repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "namespace" {
  type        = string
  description = "The namespace where the application should be deployed"
}

variable "cluster_ingress_hostname" {
  type        = string
  description = "Ingress hostname of the IKS cluster."
}

variable "cluster_type" {
  type        = string
  description = "The cluster type (openshift or ocp3 or ocp4 or kubernetes)"
}

variable "tls_secret_name" {
  type        = string
  description = "The name of the secret containing the tls certificate values"
  default     = ""
}

variable "image_tag" {
  type        = string
  description = "The image version tag to use"
  default     = "v1.4.4"
}
