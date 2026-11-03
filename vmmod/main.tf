resource "aws_key_pair" "main" {
  key_name   = "${var.env}-${var.key_pair_name}"
  public_key = var.public_key

}

data "aws_vpc" "main" {
  state = "available"
}

resource "aws_security_group" "main" {
  name        = "${var.env}-${var.security_group_name}"
  vpc_id      = data.aws_vpc.main.id # Replace with your actual VPC ID
  description = "Security group managed by dynamic blocks"

  # Dynamic block looping over the ingress_ports variable
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Standard outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env}-${var.security_group_name}"
    Env  = var.env
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create instance
resource "aws_instance" "main" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.main.key_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  root_block_device {
    volume_size = var.env == "dev" ? 10 : 20
    volume_type = "gp3"
  }

  tags = {
    Name   = "${var.env}-${var.instance_name}"
    Env    = var.env
    Owners = "Self"
  }
}

