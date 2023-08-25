provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-east-1"
  
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

resource "aws_subnet" "dev-private-subnet2" {
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "dev-private-subnet2"
  }
}

resource "aws_eip" "dev-eip1" {
  tags = {
    "Name" = "dev-eip1"
  }
  
}

resource "aws_eip" "dev-eip2" {
  tags = {
    "Name" = "dev-eip2"
  }
  
}

resource "aws_nat_gateway" "dev-ngw1" {
  allocation_id = aws_eip.dev-eip1.id
  subnet_id     = aws_subnet.dev-public-subnet1.id

  tags = {
    "Name" = "dev-ngw1"
  }
  depends_on = [aws_internet_gateway.dev-gw]
}

resource "aws_nat_gateway" "dev-ngw2" {
  allocation_id = aws_eip.dev-eip2.id
  subnet_id     = aws_subnet.dev-public-subnet2.id

  tags = {
    "Name" = "dev-ngw2"
  }
  depends_on = [aws_internet_gateway.dev-gw]
}

resource "aws_route_table" "dev-public-rt" {
  vpc_id = aws_vpc.dev-vpc.id

  route = []

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "public-internet-route" {
  route_table_id            = aws_route_table.dev-public-rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dev-gw.id
}

resource "aws_route_table_association" "public-rt-assoc1" {
  subnet_id      = aws_subnet.dev-public-subnet1.id
  route_table_id = aws_route_table.dev-public-rt.id
}

resource "aws_route_table_association" "public-rt-assoc2" {
  subnet_id      = aws_subnet.dev-public-subnet2.id
  route_table_id = aws_route_table.dev-public-rt.id
}

resource "aws_route_table" "dev-private-rt1" {
  vpc_id = aws_vpc.dev-vpc.id

  route = []

  tags = {
    Name = "dev-private-rt1"
  }
}

resource "aws_route_table" "dev-private-rt2" {
  vpc_id = aws_vpc.dev-vpc.id

  route = []

  tags = {
    Name = "dev-private-rt2"
  }
}

resource "aws_route" "private-internet-rt1" {
  route_table_id            = aws_route_table.dev-private-rt1.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.dev-ngw1.id
}

resource "aws_route" "private-internet-rt2" {
  route_table_id            = aws_route_table.dev-private-rt2.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.dev-ngw2.id
}

resource "aws_route_table_association" "private-rt-assoc1" {
  subnet_id      = aws_subnet.dev-private-subnet1.id
  route_table_id = aws_route_table.dev-private-rt1.id
}

resource "aws_route_table_association" "private-rt-assoc2" {
  subnet_id      = aws_subnet.dev-private-subnet2.id
  route_table_id = aws_route_table.dev-private-rt2.id
}


resource "aws_security_group" "alb-sg" {
  name_prefix = "alb-sg"
  description = "alb-sg"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description      = "alb-sg"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "alb-sg"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "webserver-sg" {
  name_prefix = "webserver-sg"
  description = "webserver-sg"
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "webserver-sg"
  }
}