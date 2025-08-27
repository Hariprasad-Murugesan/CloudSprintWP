terraform {
  backend "s3" {
    bucket         = "cloudsprint-terraform-state-2025"
    key            = "cloudsprint-infra/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
  }
}