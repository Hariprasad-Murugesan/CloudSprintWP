variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "your-key-pair-name"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "wordpress"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}