output "ec2_public_dns" {
  description = "EC2 Public DNS"
  value       =  module.dev-infra.ec2_public_dns
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = module.dev-infra.ec2_public_ip
}