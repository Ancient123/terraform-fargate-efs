# Use >4.0 Terraform AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Use US-East-2 because US-East-1 isn't great
provider "aws" {
  region = "us-east-2"
}

# Make aws region accessable as a var
data "aws_region" "current" {}

# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get Subnets for Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get default ECS Cluster for Fargate
data "aws_ecs_cluster" "default" {
  cluster_name = "Main"
}
