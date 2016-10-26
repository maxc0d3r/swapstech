provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.prod_region}"
}

# Create production VPC
resource "aws_vpc" "prod" {
  cidr_block = "${var.prod_vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "Production VPC"
  }
}

# Create Internet Gateway for production VPC
resource "aws_internet_gateway" "prod-gateway" {
  vpc_id = "${aws_vpc.prod.id}"
}

# Create Public Subnet in us-east-1a AZ
resource "aws_subnet" "us-east-1a-public" {
  vpc_id = "${aws_vpc.prod.id}"
  cidr_block = "${var.prod_vpc_public_subnet_1_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Public Subnet 1"
  }
}

# Create Public Subnet in us-east-1b AZ
resource "aws_subnet" "us-east-1b-public" {
  vpc_id = "${aws_vpc.prod.id}"
  cidr_block = "${var.prod_vpc_public_subnet_2_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Public Subnet 2"
  }
}

# Create Private Subnet in us-east-1a AZ
resource "aws_subnet" "us-east-1a-private" {
  vpc_id = "${aws_vpc.prod.id}"
  cidr_block = "${var.prod_vpc_private_subnet_1_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name = "Private Subnet 1"
  }
}

# Create Private Subnet in us-east-1b AZ
resource "aws_subnet" "us-east-1b-private" {
  vpc_id = "${aws_vpc.prod.id}"
  cidr_block = "${var.prod_vpc_private_subnet_2_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name = "Private Subnet 2"
  }
}

# Create Private Subnet in us-east-1d AZ
resource "aws_subnet" "us-east-1d-private" {
  vpc_id = "${aws_vpc.prod.id}"
  cidr_block = "${var.prod_vpc_private_subnet_3_cidr}"
  availability_zone = "us-east-1d"

  tags {
    Name = "Private Subnet 3"
  }
}

# Create Route Table for Public Subnets
resource "aws_route_table" "prod-public" {
  vpc_id = "${aws_vpc.prod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prod-gateway.id}"
  }

  tags {
    Name = "Public Subnets"
  }
}

# Create Route Table for Private Subnets
resource "aws_route_table" "prod-private" {
  vpc_id = "${aws_vpc.prod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.prod-nat.id}"
  }

  tags {
    Name = "Private Subnets"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "us-east-1a-public" {
  subnet_id = "${aws_subnet.us-east-1a-public.id}"
  route_table_id = "${aws_route_table.prod-public.id}"
}

resource "aws_route_table_association" "us-east-1b-public" {
  subnet_id = "${aws_subnet.us-east-1b-public.id}"
  route_table_id = "${aws_route_table.prod-public.id}"
}

resource "aws_route_table_association" "us-east-1a-private" {
  subnet_id = "${aws_subnet.us-east-1a-private.id}"
  route_table_id = "${aws_route_table.prod-private.id}"
}

resource "aws_route_table_association" "us-east-1b-private" {
  subnet_id = "${aws_subnet.us-east-1b-private.id}"
  route_table_id = "${aws_route_table.prod-private.id}"
}

resource "aws_route_table_association" "us-east-1d-private" {
  subnet_id = "${aws_subnet.us-east-1d-private.id}"
  route_table_id = "${aws_route_table.prod-private.id}"
}

# Security group for NAT instance
resource "aws_security_group" "prod-nat" {
  name = "prod_nat"
  description = "Allow traffic to pass from private subnet in Production VPC to Internet"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.prod_vpc_cidr}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["${var.prod_vpc_cidr}"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.prod_vpc_cidr}"]
  }
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.prod.id}"

  tags {
    Name = "NATSG"
  }
}

resource "aws_key_pair" "upwork-test" {
  key_name = "upwork-test"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJ1em2uxFXLX2nQ/W7O7L0D+1S9GonhqeKdTm0E4jXFjxFw5eEVl5fqW7Xuzl/UTLZhIRvG3x/4ANOVvahOdwd79ERIDQNoJHusnuZAoj0ekzllczwOp8R4Ylx5ulCKQbMDVXRzhhO125MzHVEqFMRnzF0lQES6gW/I4CqhkOYZ1kc5dVt2WlKyZSNRm5JaFgRnRZZFPnqNrfsELJGrZGFZbguQRkDJVKCtl2C/Lhc/E1jCadLP3C8PdLD9ehTxLLlT7ryGgGrdZocN3Pe1tkcwMFlemo1G9AmdW2R+9K04B5OSRSjb1yOUNlxGpdXtOLP2PErHsibi1JgNWZZTx//nwZ1GsmAAMAs82wBMJ6YZKOyf9JYEaU+9rHVQGnvj0RsR0BSnJvr0l0Y7e1AXXpULu65GytMXjXAFfKFFlsVb9MGK+DdyoL+MaEFu1vJ4E3j7QlUvv8H+gPQWesCxRjrFhyOcpYZg6kKbB3T+NaYvPFU2C6kI0Ygpj0W5wcoLzeqWtnnvfE5mkZLCY0lrv25u2iuJu23dcZQmwNXPg+K49/0d0P6bG9AyMZPQR3WgOSWn9V6Hl3FaaLMTWLN1saTk95Z9V+iQ0VEoOjDocY6NXTqCT/nPEx+9gp2ojC6VupnXhhrLZy2rwFiNJF1+SUbPgs+N9RffGboLczfMzHKaw== mail2mayank@gmail.com"
}

resource "aws_instance" "prod-nat" {
  ami = "ami-d2ee95c5"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.prod-nat.id}"]
  subnet_id = "${aws_subnet.us-east-1a-public.id}"
  associate_public_ip_address = true
  source_dest_check = false
  tags {
    Name = "Production NATBox"
  }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.prod-nat.id}"
    vpc = true
}
