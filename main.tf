provider "aws" {
  
}

resource "aws_vpc" "dev-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        "Name" = "dev-vpc"
    }
  
}
resource "aws_internet_gateway" "dev-gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

resource "aws_subnet" "dev-public-subnet1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet1"
  }
}

resource "aws_subnet" "dev-public-subnet2" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet2"
  }
}

resource "aws_subnet" "dev-private-subnet1" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "dev-private-subnet1"
  }
}

resource "aws_subnet" "dev-public-subnet2" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "dev-public-subnet2"
  }
}
