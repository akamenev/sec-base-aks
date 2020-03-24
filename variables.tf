# variable "kubernetes_client_id" {
#   description = "The Client ID for the Service Principal to use for this Managed Kubernetes Cluster"
# }

# variable "kubernetes_client_secret" {
#   description = "The Client Secret for the Service Principal to use for this Managed Kubernetes Cluster"
# }

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "VAR_KUBE_RG"
#     storage_account_name = "VAR_TERRAFORM_NAME"
#     container_name       = "tfstate"
#     key                  = "fw-hub-aks.tfstate"
#   }
# }

variable "cluster_name" {
  default = "fw-hub-aks"
}

variable "username" {
  default = "akamenev"
}

variable "resource_group_name" {
  default = "fw-hub-aks"
}

variable "location" {
  default = "WestEurope"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "fw-hub-aks"
}

variable "kubernetes_version" {
  default = "1.15.7"
}