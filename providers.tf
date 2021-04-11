# MWAA providers

terraform {
  # backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.36.0"
    }
  }

  required_version = ">= 0.14.0, < 0.15.0"
}

provider "aws" {
  region = var.region
}
