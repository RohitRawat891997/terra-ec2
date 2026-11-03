# Terra Practice

This project is a simple Terraform learning repository created to provision a basic AWS infrastructure using Infrastructure as Code (IaC). It is designed for beginners who want to understand how Terraform works in real life, especially for creating a virtual machine, security group, SSH access, and remote state storage.

The project is intentionally small and focused on one purpose: create a secure Ubuntu-based EC2 instance on AWS and keep the Terraform state in an S3 bucket.

## Project purpose

This repository exists to demonstrate:

- Terraform configuration basics
- AWS provider usage
- Reusable Terraform modules
- Remote backend configuration with S3
- EC2 instance creation
- Security group configuration
- Key pair setup for SSH access
- Terraform outputs for useful runtime information

This is a practice project. It is meant for learning, testing, and hands-on understanding of Terraform, not as a production-ready enterprise deployment.

## What this project creates

When you run the Terraform code in this repository, it will create:

- An AWS EC2 instance running Ubuntu 24.04
- An SSH key pair for the instance
- A security group with inbound rules for:
  - SSH on port 22
  - HTTP on port 80
  - HTTPS on port 443
- A default VPC lookup in the configured AWS region
- Output values showing the VPC CIDR and EC2 public IP

## Repository structure

- `main.tf` — root Terraform configuration
- `vmmod/` — reusable Terraform module that creates the virtual machine infrastructure
- `vmmod/main.tf` — EC2, security group, key pair, and instance setup logic
- `vmmod/variables.tf` — module input variables
- `vmmod/outputs.tf` — output values returned after deployment
- `.gitignore` — common ignore rules

## Root configuration explained

The root file `main.tf` does the following:

1. Configures the Terraform required AWS provider.
2. Uses an S3 backend to store Terraform state remotely.
3. Sets the AWS region to `us-east-1`.
4. Calls the local module `./vmmod`.
5. Passes values such as environment, instance name, instance type, and SSH public key.

Example values used by the project:

- Environment: `dev`
- Instance name: `web-server`
- Instance type: `t2.micro`
- SSH public key: loaded from `./terra-key`

The backend block is:

```hcl
backend "s3" {
  bucket       = "my-terraform-state-bucket"
  key          = "terra-backup/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

This means your Terraform state is stored in an S3 bucket instead of a local file. This is useful for team collaboration and safer infrastructure management.

## Module explanation

The `vmmod` module contains the actual infrastructure logic.

### 1. Key pair creation

Terraform creates an AWS key pair using the public key you provide.

```hcl
resource "aws_key_pair" "main" {
  key_name   = "${var.env}-${var.key_pair_name}"
  public_key = var.public_key
}
```

This allows you to connect to the EC2 instance using the matching private key.

### 2. VPC lookup

Terraform looks up the available VPC in the AWS account and uses it for the security group.

```hcl
data "aws_vpc" "main" {
  state = "available"
}
```

### 3. Security group

The security group opens ports for:

- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)

This is done using a dynamic ingress block so rules are generated from a list of objects.

### 4. EC2 instance creation

Terraform launches an Ubuntu instance using Canonical Ubuntu AMI and the defined instance type.

```hcl
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.main.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
}
```

The root block device is configured with:

- 10 GB for `dev`
- 20 GB for non-dev environments

### 5. Outputs

After deployment, Terraform prints:

- VPC CIDR block
- EC2 public IP

These outputs help you know where the instance is running and how to connect to it.

## Important variables

The module defines the following variables:

- `env` — environment name, default `prd`
- `key_pair_name` — AWS key pair name, default `terra-key`
- `public_key` — public SSH key content
- `instance_name` — instance tag name
- `instance_type` — EC2 size, default `t2.micro`
- `instance_volume_size` — root disk size
- `security_group_name` — security group name
- `ingress_ports` — list of allowed inbound ports and CIDR ranges

## Prerequisites

Before running this project, make sure you have:

- An AWS account
- IAM credentials with permission to create EC2, VPC-related resources, key pairs, and security groups
- Terraform installed on your machine
- AWS CLI configured or environment variables set
- An S3 bucket created in the configured region

## Required setup steps

### 1. Create the SSH key pair

Run:

```bash
ssh-keygen -t rsa -b 4096 -f ./terra-key -N ""
```

This creates:

- `terra-key` (private key)
- `terra-key.pub` (public key)

The public key is read by Terraform from `./terra-key` as configured in the root module.

### 2. Create the S3 backend bucket

Because the Terraform backend is configured to use S3, the bucket must exist first.

Example:

```bash
aws s3api create-bucket \
  --bucket my-terraform-state-bucket \
  --region us-east-1
```

If you use a different AWS region or bucket name, update the backend block in `main.tf` accordingly.

### 3. Configure AWS credentials

Set your AWS credentials using either AWS CLI or environment variables:

```bash
aws configure
```

Or:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Review the plan

```bash
terraform plan
```

### 6. Apply the infrastructure

```bash
terraform apply
```

If you want to skip confirmation:

```bash
terraform apply -auto-approve
```

## Connect to the EC2 instance

After deployment, Terraform will output the instance public IP.

You can then connect using:

```bash
ssh -i terra-key ubuntu@<public-ip>
```

Example:

```bash
ssh -i terra-key ubuntu@54.123.45.67
```

## Destroy the infrastructure

When you no longer need the environment:

```bash
terraform destroy
```

To skip the confirmation prompt:

```bash
terraform destroy -auto-approve
```

## Security note

This project opens SSH, HTTP, and HTTPS ports publicly. That is useful for learning and testing, but in a real production system you should:

- Restrict SSH access to a trusted IP range
- Only expose necessary ports
- Use least-privilege IAM permissions
- Put resources in a proper VPC design
- Use private subnets for non-public services

## Why this project is useful

This repo is useful because it shows a complete beginner-friendly Terraform flow:

- Terraform code defines infrastructure
- Variables make it configurable
- Modules help organize code
- Outputs expose important runtime values
- Remote state is managed in S3
- AWS resources are created automatically from code

This is the exact practical workflow used in real DevOps environments.

## Best use case

This project is best used for:

- Learning Terraform from scratch
- Practising AWS resource provisioning
- Building a demo environment for web servers
- Testing Terraform module patterns
- Understanding remote state and basic IaC workflows

## Final summary

This repository is a small but complete Terraform project that demonstrates how to create a simple AWS web server environment. It uses a reusable module and shows the core concepts of Terraform in one place.

If you read and use this file as a guide, you should be able to:

- understand the goal of the project
- know which resources are created
- configure the required AWS and Terraform setup
- deploy the environment
- connect to the EC2 instance
- destroy the infrastructure when done

This project is a practical hands-on example for learning Terraform and AWS automation.
