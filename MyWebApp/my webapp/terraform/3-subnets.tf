resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]

  tags = {
    Name                        = "public_us_east_1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.65.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  depends_on              = [aws_internet_gateway.gw]

  tags = {
    Name                        = "public_us_east_1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.128.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                        = "private_us_east_1a"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.192.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                        = "private_us_east_1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}