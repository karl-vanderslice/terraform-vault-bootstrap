terraform {
  required_version = ">= 1.6.0"

  cloud {
    hostname     = "app.terraform.io"
    organization = "karl-vanderslice-org"

    workspaces {
      name = "terraform-vault-bootstrap"
    }
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.8"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}

provider "vault" {
  address   = var.vault_addr
  token     = var.vault_token
  namespace = var.vault_namespace
}

provider "aws" {
  region = var.aws_region
}
