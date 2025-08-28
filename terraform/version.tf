terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10"  # Match the version in your lock file
    }
  }

  backend "s3" {
    bucket         = "cloudsprint-terraform-state-2025"
    key            = "cloudsprint-infra/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}