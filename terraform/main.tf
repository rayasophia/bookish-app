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
  availability_zone       = "us-east-2a"
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

resource "aws_route_table" "bookish_public_rt" {
  vpc_id = aws_vpc.bookish_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.bookish_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bookish_internet_gateway.id
}

resource "aws_route_table_association" "bookish_public_subnet_association" {
  subnet_id      = aws_subnet.bookish_public_subnet.id
  route_table_id = aws_route_table.bookish_public_rt.id
}

resource "aws_security_group" "bookish_sg" {
  name        = "dev-sg"
  description = "dev security group"
  vpc_id      = aws_vpc.bookish_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["184.146.156.29/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bookish_auth" {
  key_name   = "bookishkey"
  public_key = file("~/.ssh/bookishkey.pub")
}

resource "aws_instance" "dev_node" {
  ami           = data.aws_ami.server_ami.id
  instance_type = "t2.micro" # free tier
  key_name      = aws_key_pair.bookish_auth.key_name
  subnet_id     = aws_subnet.bookish_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bookish_sg.id]
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-node"
  }
}