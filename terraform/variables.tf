
variable "cluster_name" {
  default = "sec-aks"
}

variable "username" {
  default = "aksadmin"
}

variable "resource_group_name" {
  default = "sec-aks"
}

variable "location" {
  default = "WestEurope"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "sec-aks"
}

variable "kubernetes_version" {
  default = "1.15.7"
}

variable "acr_name" {
  default = "secureacr"
}
