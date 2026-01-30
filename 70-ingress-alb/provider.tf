terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.93.0"
    }
  }

  backend "s3" {
    bucket = "expense-project-dev"
    key    = "expense-dev-web-alb-jenkins" # you should have unique keys with in the bucket, same key should not be used in other repos or tf projects
    region = "us-east-1"
    dynamodb_table = "expense-project-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}