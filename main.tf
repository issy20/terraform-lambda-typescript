terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "SPOTIFY_REFRESH_TOKEN" {
  type = string
}
variable "SPOTIFY_CLIENT_ID" {
  type = string
}
variable "SPOTIFY_CLIENT_SECRET" {
  type = string
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# terraform plan -var-file="terraform.tfvars"
# terraform apply -var-file="terraform.tfvars"
# terraform destroy -var-file="terraform.tfvars"
