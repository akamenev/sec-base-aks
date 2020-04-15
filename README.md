# Security Baseline AKS
The goal of this repo is to have a baseline secure AKS setup with private Kubernetes API and egress traffic lockdown

## Architecture Diagram

![Architecture](images/aks-fw.png)

## Out of Scope
* In-cluster Security (Network Policies, OPA, mTLS, etc)
* Secure CI/CD pipelines
* Container Security (AppArmor, seccomp)

## How to start

### Download and Install Terraform
Download a proper package for your operating system from [here](https://www.terraform.io/downloads.html). Alternatively, you can use [Azure Cloud Shell](https://shell.azure.com/), that has Terraform binary pre-installed.

### Download and Install Azure CLI
Follow the instructions for your operating system [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). Alternatively, you can use [Azure Cloud Shell](https://shell.azure.com/), that has Azure CLI binary pre-installed.

### Clone this repo and go to a terraform directory
```bash
git clone https://github.com/akamenev/sec-base-aks
cd sec-base-aks/terraform
```
Templates structure:
```bash
terraform
├── acr.tf          # contains ACR deployment with ACR Firewall Rules
├── akscni.tf       # contains AKS deployment with DNS Private Zone Link
├── firewall.tf     # contains Azure Firewall deployment with Network and Application rules and Route Table
├── jumpbox.tf      # contains Jumpbox VM deployment
├── logs.tf         # contains Azure Log Analytics deployment
├── providers.tf    # contains required Terraform Providers (azurerm)
├── variables.tf    # contains required variables
└── vnet.tf         # contains Resource Group and Virtual Network deployments
```


### Login to Azure with Azure CLI and Set the Environment Variables
```bash
az login

export TF_VAR_cluster_name="sec-aks"               # Name of a cluster
export TF_VAR_username="aksadmin"                  # Username for a jumpbox and cluster user
export TF_VAR_resource_group_name="sec-aks"        # Resource group name
export TF_VAR_location="WestEurope"                # Location 
export TF_VAR_ssh_public_key="~/.ssh/id_rsa.pub"   # Location of ssh key to use
export TF_VAR_dns_prefix="sec-aks"                 # DNS prefix for a cluster
export TF_VAR_kubernetes_version="1.15.7"          # Cluster version
export TF_VAR_acr_name="secureacr"                 # Name of container registry
```

### Initialize Terraform and apply the template
```bash
terraform init
terraform apply
```

### Delete the environment
```bash
terraform destroy
```
