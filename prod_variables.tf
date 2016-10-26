variable "prod_route53_zone_private" {
  description = "Internal Domain name for production environment"
  default = "prod.swapstech.tv"
}

variable "prod_route53_zone_public" {
  description = "External Domain name for production environment"
  default = "swapstech.com"
}

variable "prod_vpc_cidr" {
  description = "CIDR for production VPC"
  default = "10.0.0.0/16"
}

variable "prod_public_subnets" {
  type = "map"
  default = {
    az1.cidr = "10.0.1.0/24",
    az1.availability_zone = "us-east-1a",
    az2.cidr = "10.0.2.0/24",
    az2.availability_zone = "us-east-1b"
  }
}

variable "prod_private_subnets" {
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


variable "prod_asgs" {
  type = "map"
  default = {
    tomcat.min = 1,
    tomcat.max = 2,
    tomcat.desired = 2,
    rabbitmq.min = 1,
    rabbitmq.max = 2,
    rabbitmq.desired = 2
  }
}
