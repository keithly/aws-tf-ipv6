terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      project = "https://github.com/keithly/aws-tf-ipv6"
    }
  }
}
