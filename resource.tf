#Vpc Creation
resource "aws_vpc" "mahi" {
  cidr_block = "13.0.0.0/16"

  tags = {
    Name = "my-custom"
  }
}

#subnets creation
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.mahi.id
  cidr_block        = "13.0.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.mahi.id
  cidr_block        = "13.0.2.0/24"
  availability_zone = "us-west-1b"

  tags = {
    Name = "private"
  }
}

#create IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mahi.id

  tags = {
    Name = "IGW-custom"
  }
}

#creating public route table
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.mahi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-RT"
  }
}

#subnet association

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_RT.id
}

#EIP

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-EIP"
  }
}

# Nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "gw NAT"
  }
}

#creating private RT and alllow NAT GW
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.mahi.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-RT"
  }
}

#Associate private subnet to Private-RT
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_RT.id
}
