terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "my-terraform-state-bucket"
    key          = "terra-backup/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

locals {
  AWS_REGION_US = "us-east-1"
}

provider "aws" {
  region = local.AWS_REGION_US
}

module "dev-infra" {
  source        = "./vmmod"
  env           = "dev"
  instance_name = "web-server"
  instance_type = "t2.micro"
  public_key    = file("terra-key")
}
