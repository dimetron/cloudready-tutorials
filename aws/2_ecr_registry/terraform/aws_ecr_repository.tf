terraform {
  required_version = ">= 0.13, < 0.14"
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.0"
}

resource "aws_ecr_repository" "ecr" {
  name                 = "devops-cli"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}