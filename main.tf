terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "oficina-terraform-state-gtx"
    key    = "k8s/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "oficina"
      Phase     = "fase-3"
      ManagedBy = "terraform"
      Repo      = "oficina-infra-k8s"
    }
  }
}

# Consome a VPC criada pelo repositório oficina-infra-database
data "terraform_remote_state" "database" {
  backend = "s3"
  config = {
    bucket = "oficina-terraform-state-gtx"
    key    = "database/terraform.tfstate"
    region = "us-east-1"
  }
}
