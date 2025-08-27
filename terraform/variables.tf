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
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"]
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Add these to your variables.tf file
variable "wp_auth_key" {
  description = "WordPress AUTH_KEY"
  type        = string
  sensitive   = true
}

variable "wp_secure_auth_key" {
  description = "WordPress SECURE_AUTH_KEY"
  type        = string
  sensitive   = true
}

variable "wp_logged_in_key" {
  description = "WordPress LOGGED_IN_KEY"
  type        = string
  sensitive   = true
}

variable "wp_nonce_key" {
  description = "WordPress NONCE_KEY"
  type        = string
  sensitive   = true
}

variable "wp_auth_salt" {
  description = "WordPress AUTH_SALT"
  type        = string
  sensitive   = true
}

variable "wp_secure_auth_salt" {
  description = "WordPress SECURE_AUTH_SALT"
  type        = string
  sensitive   = true
}

variable "wp_logged_in_salt" {
  description = "WordPress LOGGED_IN_SALT"
  type        = string
  sensitive   = true
}

variable "wp_nonce_salt" {
  description = "WordPress NONCE_SALT"
  type        = string
  sensitive   = true
}