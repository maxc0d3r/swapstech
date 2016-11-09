variable "environment" {
  default = "Test"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "infra_regions" {
  default = "us-east-1,us-east-2"
}

variable "route53_zone_private" {
  description = "Internal Domain name"
  default = "prod.swapstech.tv"
}

variable "route53_zone_public" {
  description = "External Domain name"
  default = "swapstech.com"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  default = "Production VPC"
}

variable "peer_vpc_cidr" {
  description = "CIDR block for Peer VPC"
  default = "10.181.0.0/16"
}

variable "public_subnets" {
  type = "map"
  default = {
    az1.cidr = "10.0.1.0/24",
    az1.availability_zone = "us-east-1a",
    az2.cidr = "10.0.2.0/24",
    az2.availability_zone = "us-east-1b"
  }
}

variable "private_subnets" {
  type = "map"
  default = {
    az1.cidr = "10.0.3.0/24",
    az1.availability_zone = "us-east-1a",
    az2.cidr = "10.0.4.0/24",
    az2.availability_zone = "us-east-1b",
    az3.cidr = "10.0.5.0/24",
    az3.availability_zone = "us-east-1d"
  }
}

variable "custom_network_cidr" {
  default = "0.0.0.0/0"
}

variable "iam_instance_profile" {}
