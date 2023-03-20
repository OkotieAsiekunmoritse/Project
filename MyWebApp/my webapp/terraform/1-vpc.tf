resource "aws_vpc" "main" {
  # Resource Link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
  # VPC CIDR Block

  cidr_block = "10.0.0.0/16"

  # Makes all instancess shared on the host
  instance_tenancy = "default"

  enable_dns_hostnames = true

  enable_dns_support = true


  tags = {
    Name = "main"
  }
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "aws vpc id"
  sensitive   = false

}