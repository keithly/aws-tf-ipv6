terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"

  default_tags {
    tags = {
      environment = "prod"
      project     = "aws-tf-ipv6"
    }
  }
}
