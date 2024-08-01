terraform {

  required_version = "1.7.5"

  backend "s3" {
    bucket                = "terraform-remote-state-vault"
    encrypt               = true
    workspace_key_prefix  = "vault_k8s"
    key                   = "vault_cluster/terraform.tfstate"
    region                = "eu-west-1"
    dynamodb_table        = "terraform_statelock"
  }

  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = var.config_context
  }

  # localhost registry with password protection
  #  registry {
  #    url = "oci://registry.mediaset.es/swhelm"
  #    username = "t1-frivas"
  #    password = ""
  #  }
}

provider "vault" {
  address = var.vault_addr
  token = ""
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.config_context
}

#locals {
#  vault_addr = {
#    azr_pre  = "https://pazrvaultcluster01.mediaset.es:8200"
#    aws_pre  = "https://pawsvaultcluster01.mediaset.es:8200"
#    aws_pro  = "https://awsvault.mediaset.es:8200"
#    mds_pro  = "https://vault.mediaset.es:8200"
#  }
#}