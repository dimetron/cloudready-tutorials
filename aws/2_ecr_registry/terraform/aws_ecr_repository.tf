terraform {
  required_version = ">= 0.13, < 0.14"
}

provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.0"
}

resource "aws_ecr_repository" "ecr" {
  name                 = "ecr_repository"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr1" {
  name                 = "ecr_repository/devops-cli"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ecr2" {
  name                 = "ecr_repository/base-image"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}