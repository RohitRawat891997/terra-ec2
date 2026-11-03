# Terra EC2

This project is a beginner-friendly Terraform practice repository for creating an Amazon EC2 instance on AWS using Infrastructure as Code (IaC).

The goal of the project is to show how Terraform can automate the provisioning of cloud infrastructure in a simple, readable, and reusable way.

## Project purpose

This repository demonstrates:

- Terraform project structure
- AWS provider configuration
- Reusable Terraform modules
- EC2 instance provisioning
- Security group creation
- SSH key pair setup
- Remote Terraform state using S3 backend
- Output values for public access information

This is a learning project and is intended for practice, demo, and experimentation.

## What this project creates

When you run Terraform in this repository, it creates:

- An Ubuntu EC2 instance
- An AWS key pair for SSH access
- A security group with inbound access on:
  - port 22 (SSH)
  - port 80 (HTTP)
  - port 443 (HTTPS)
- A VPC lookup based on the default available VPC in the AWS account
- Outputs exposing the instance public DNS and public IP

## Repository structure

- `main.tf` — root Terraform configuration
- `outputs.tf` — root outputs that expose values from the child module
- `vmmod/` — reusable module for infrastructure creation
- `vmmod/main.tf` — EC2, security group, and networking configuration
- `vmmod/variables.tf` — module inputs
- `vmmod/outputs.tf` — EC2 public DNS and public IP outputs
- `.gitignore` — ignore file for local Terraform files

## Root configuration

The root `main.tf` file configures:

1. Terraform and AWS provider
2. S3 backend for Terraform state
3. Default AWS region (`us-east-1`)
4. A local module called `./vmmod`
5. Module inputs like environment, instance name, instance type, and SSH public key

```hcl
terraform {
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
```

The root module calls the custom module as shown below:

```hcl
module "dev-infra" {
  source        = "./vmmod"
  env           = "dev"
  instance_name = "web-server"
  instance_type = "t2.micro"
  public_key    = file("./terra-key")
}
```

This means Terraform will use the `vmmod` module to create the AWS infrastructure.

## Module behavior

The `vmmod` module contains the real infrastructure logic.

### 1. SSH key pair

Terraform creates an AWS EC2 key pair using the public key you provide.

```hcl
resource "aws_key_pair" "main" {
  key_name   = "${var.env}-${var.key_pair_name}"
  public_key = var.public_key
}
```

### 2. VPC lookup

Terraform finds the available VPC in the AWS account and uses it for the security group.

```hcl
data "aws_vpc" "main" {
  state = "available"
}
```

### 3. Security group

The module creates a security group that allows inbound traffic on:

- 22 for SSH
- 80 for HTTP
- 443 for HTTPS

The ingress rules are defined using a variable list and a dynamic `ingress` block.

### 4. Ubuntu AMI lookup

Terraform looks up the latest Ubuntu 24.04 AMI for the region.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

### 5. EC2 instance creation

The EC2 instance is created with:

- Ubuntu AMI
- selected instance type
- key pair
- security group
- root volume size based on environment

```hcl
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.main.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}
```

## Outputs

The module exposes:

- `ec2_public_dns`
- `ec2_public_ip`

At the root level, `outputs.tf` passes those values to the top-level project:

```hcl
output "ec2_public_dns" {
  description = "EC2 Public DNS"
  value       = module.dev-infra.ec2_public_dns
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.dev-infra.ec2_public_ip
}
```

These outputs help you know where the EC2 instance is running and how to connect to it.

## Variables used by the module

The module supports the following variables:

- `env` — environment name
- `key_pair_name` — key pair name
- `public_key` — SSH public key content
- `instance_name` — EC2 instance name
- `instance_type` — EC2 instance size
- `security_group_name` — security group name
- `ingress_ports` — allowed inbound rules

## Prerequisites

Before running this project, ensure you have:

- An AWS account
- AWS credentials configured
- Terraform installed
- An S3 bucket for remote state created in the required region
- A generated SSH key pair

## Generate SSH key

Run the following command:

```bash
ssh-keygen -t rsa -b 4096
```

This will create a private/public key pair. The public key is passed to Terraform using `file("./terra-key")` in the root configuration.

If you want a custom key file name:

```bash
ssh-keygen -t rsa -b 4096 -f ./terra-key -N ""
```

## Configure AWS credentials

You can configure AWS CLI with:

```bash
aws configure
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## Setup and deployment

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the infrastructure plan

```bash
terraform plan
```

### 3. Apply the configuration

```bash
terraform apply
```

Optional:

```bash
terraform apply -auto-approve
```

## Connect to the EC2 instance

After deployment, use the public IP or public DNS output:

```bash
ssh -i terra-key ubuntu@<public-ip>
```

Example:

```bash
ssh -i terra-key ubuntu@54.123.45.67
```

## Destroy the environment

When you no longer need the resources:

```bash
terraform destroy
```

Or:

```bash
terraform destroy -auto-approve
```

## Security note

This project opens common public ports for learning and testing. In production, you should:

- restrict SSH access to trusted IP ranges
- avoid exposing unnecessary ports
- use least-privilege IAM permissions
- keep private services in private networks when possible

## Why this project is useful

This repository is useful for:

- learning Terraform basics
- practicing AWS resource creation
- understanding modules and variables
- seeing how EC2 infrastructure is automated with code
- understanding S3 remote state usage

## Final summary

This project is a simple AWS Terraform EC2 practice setup that shows how to create infrastructure using code. It is ideal for beginners who want to understand how Terraform manages cloud resources and how modules help organize configuration.

With this repository, you can:

- understand the project structure
- provision an EC2 instance with Terraform
- configure SSH access
- view the instance connection details from outputs
- destroy the environment cleanly when finished
