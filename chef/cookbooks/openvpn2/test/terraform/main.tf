variable "name"   { default = "openvpn2-cookbook" }
variable "region" { }

variable "subnet_public_cidr" {
  default {
    us-east-1 = "10.253.0.0/24"
    us-west-1 = "10.254.0.0/24"
  }
}

variable "vpc_cidr" {
  default {
    us-east-1 = "10.253.0.0/16"
    us-west-1 = "10.254.0.0/16"
  }
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "default" {
  key_name = "${var.name}-deploy"
  public_key = "${file(\"test/terraform/insecure.pub\")}"
}

resource "aws_vpc" "default" {
  cidr_block = "${lookup(var.vpc_cidr, var.region)}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags { Name = "vpc-${var.region}-${var.name}" }
}

/* public subnet (with internet access)*/

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${lookup(var.subnet_public_cidr, var.region)}"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  tags { Name = "subnet-public-${var.region}-${var.name}" }
}

/* Internet gateways */ 

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

/* Routing tables and associations */

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags { Name = "igw-${var.region}-${var.name}" }
}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_security_group" "default" { 
  name = "${var.name}"
  vpc_id = "${aws_vpc.default.id}"
  description = "Security group to test ${var.name}"
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  /* ping */

  ingress {
    from_port   = "-1"
    to_port     = "-1"
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "${var.name}-${var.region}"
  acl = "private"
}

resource "aws_eip" "vpn" {
  vpc = true
}

output "region" {
  value = "${var.region}"
}

output "vpc.id" {
  value = "${aws_vpc.default.id}"
}

output "subnet.public.id" {
  value = "${aws_subnet.public.id}"
}

output "subnet.public.cidr" {
  value = "${aws_subnet.public.cidr_block}"
}

output "ssh_key.name" {
  value = "${aws_key_pair.default.key_name}"
}

output "sg.id" {
  value = "${aws_security_group.default.id}"
}

output "eip.vpn" {
  value = "${aws_eip.vpn.public_ip}"
}

output "s3_bucket" {
  value = "${aws_s3_bucket.default.id}"
}
