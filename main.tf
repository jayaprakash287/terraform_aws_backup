

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "aws_for_use"

    workspaces {
      name = "practive_actions"
    }
  }
}


provider "aws" {

    region = "eu-west-2"
}


