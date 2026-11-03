output "aws_vpc" {
  value = data.aws_vpc.main.cidr_block
}

output "aws_instance" {
  value = aws_instance.main.public_ip
}