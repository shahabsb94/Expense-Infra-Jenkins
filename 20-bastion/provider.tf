terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "expense-project-dev"
    region         = "us-east-1"
    key            = "Project-expense-dev-jenkins-bastion"
    dynamodb_table = "expense-project-dev"
  }
}

provider "aws" {
  region = "us-east-1"
}