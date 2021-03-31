# MWAA providers

terraform {
  # backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.19.0"
    }

    awsmwaa = {
      source  = "registry.github.com.local/shuheiktgw/aws"
      version = "~> 1.0.0"
    }
  }

  required_version = ">= 0.14.0, < 0.15.0"
}

provider "aws" {
  region = var.region
}

provider "awsmwaa" {
  region = var.region
}
