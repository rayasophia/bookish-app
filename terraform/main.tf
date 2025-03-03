resource "aws_vpc" "bookish_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "bookish_public_subnet" {
  vpc_id                  = aws_vpc.bookish_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "bookish_internet_gateway" {
  vpc_id = aws_vpc.bookish_vpc.id

  tags = {
    Name = "dev-igw"
  }
}