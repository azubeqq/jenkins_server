# variables.tf
# Переменные Terraform — все значения удобно менять в terraform.tfvars

variable "region" {
  description = "AWS region to deploy"
  type        = string
  default     = "eu-central-1"
}

variable "access_key" {
  description = "AWS access key account to deploy"
  type        = string
  default     = ""
}

variable "secret_key" {
  description = "AWS secret key account to deploy"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Tag Name for Security Group"
  type        = string
  default     = "default"
}

variable "my_ip" {
  description = "Tag Name for APP Host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "j_instance_type" {
  description = "Instance type for test ASG"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Volume size for EC2 disk"
  type        = string
  default     = "default"
}

variable "j_volume_type" {
  type        = string
  default     = "gp3"
}

variable "j_volume_size" {
  type        = string
  default     = "10"
}

# SSH key info (must be provided by you)
variable "key_name" {
  description = "Existing AWS keypair name (must exist in your account)"
  type        = string
}

variable "public_subnet_cidr" {
  description = "list of puplic subnet A cidr"
  type        = string
  default     = "10.0.10.0/24"
}

variable "j_vpc_cidr" {
  description = "list of VPC cidr"
  type        = string
  default     = "10.0.0.0/16"
  }

#variable "public_key_path" {
#  description = "Path to public key file to upload to AWS (used to create key pair if needed)"
#  type        = string
#}