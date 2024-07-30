terraform {
  required_version = "1.7.5"

  backend "s3" {
    bucket         = "terraform-remote-state-vault"
    key            = "vault_k8s/general/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform_statelock"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.25.0"
    }
  }
}

provider "github" {
  owner    = data.terraform_remote_state.github.outputs.github_owner
  base_url = data.terraform_remote_state.github.outputs.github_url
}

provider "vault" {
  address = "https://vault.mediaset.es:8200"
}

