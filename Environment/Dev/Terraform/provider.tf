provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-deel"
    key    = "dev/infra/"
    region = "us-east-1"
  }
}