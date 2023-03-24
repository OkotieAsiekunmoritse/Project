#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "web-app" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  enable_classiclink = false
  enable_classiclink_dns_support = false
  assign_generated_ipv6_cidr_block = false

  tags = tomap({
    "Name"                                      = "terraform-eks-web-app-node",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}


output "vpc_id" {
  value       = aws_vpc.web-app.id
  description = "VPC id."
  # Setting an output value as sensitive prevents Terraform from showing its value in plan and apply.
  sensitive = false
}


# resource "aws_subnet" "web-app" {
#   count = 2

#   availability_zone       = data.aws_availability_zones.available.names[count.index]
#   cidr_block              = "10.0.${count.index}.0/24"
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.web-app.id

#   tags = tomap({
#     "Name"                                      = "terraform-eks-web-app-node",
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared",
#   })
# }


resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.web-app.id
  cidr_block              = "192.168.0.0/18"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  # depends_on              = [aws_internet_gateway.web-app]

  tags = {
    Name                        = "public-us-east-1a"
    "kubernetes.io/cluster/mo-cluster" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.web-app.id
  cidr_block              = "192.168.64.0/18"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  # depends_on              = [aws_internet_gateway.web-app]

  tags = {
    Name                        = "public-us-east-1b"
    "kubernetes.io/cluster/mo-cluster" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.web-app.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = "us-east-1a"

  tags = {
    Name                        = "private-us-east-1a"
    "kubernetes.io/cluster/mo-cluster" = "shared"
    "kubernetes.io/role/internal-elb"    = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.web-app.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = "us-east-1b"

  tags = {
    Name                        = "private_us_east_1b"
    "kubernetes.io/cluster/mo-cluster" = "shared"
    "kubernetes.io/role/internal-elb"    = 1
  }
}

# Declare security group
# resource "aws_security_group" "allow_web_traffic" {
#   name        = "allow_web traffic"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = "${aws_vpc.web-app.id}"

#   ingress {
#     description      = "HTTPS Policy"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "HTTP Policy"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   ingress {
#     description      = "SSH Policy"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   } 

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_web_traffic"
#   }
# }


# resource "aws_internet_gateway" "web-app" {
#   vpc_id = aws_vpc.web-app.id

#   tags = {
#     Name = "terraform-eks-web-app"
#   }
# }

resource "aws_internet_gateway" "web-app" {
  vpc_id = aws_vpc.web-app.id

  tags = {
    Name = "web-app"
  }
}

# resource "aws_route_table" "web-app" {
#   vpc_id = aws_vpc.web-app.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.web-app.id
#   }
# }

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.web-app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-app.id
  }
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.web-app.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id =  aws_nat_gateway.gw1.id
  }
  tags = {
    Name = "private1"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.web-app.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw2.id
  }
  tags = {
    Name = "private2"
  }
}


# resource "aws_route_table_association" "web-app" {
#   count = 2

#   subnet_id      = aws_subnet.web-app[count.index].id
#   route_table_id = aws_route_table.web-app.id
# }


resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private2.id
}