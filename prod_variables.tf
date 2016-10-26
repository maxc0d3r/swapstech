variable "prod_vpc_cidr" {
  description = "CIDR for production VPC"
  default = "10.0.0.0/16"
}

variable "prod_vpc_public_subnet_1_cidr" {
  description = "CIDR for public subnet in az1"
  default = "10.0.1.0/24"
}

variable "prod_vpc_public_subnet_2_cidr" {
  description = "CIDR for public subnet in az2"
  default = "10.0.2.0/24"
}

variable "prod_vpc_private_subnet_1_cidr" {
  description = "CIDR for private subnet in az1"
  default = "10.0.3.0/24"
}

variable "prod_vpc_private_subnet_2_cidr" {
  description = "CIDR for private subnet in az2"
  default = "10.0.4.0/24"
}

variable "prod_vpc_private_subnet_3_cidr" {
  description = "CIDR for private subnet in az3"
  default = "10.0.5.0/24"
}

variable "prod_tomcat_asg_min" {
  description = "Minimum number of servers in tomcat cluster"
  default = 1
}

variable "prod_tomcat_asg_max" {
  description = "Maximum number of servers in tomcat cluster"
  default = 2
}

variable "prod_tomcat_asg_azs" {
  description = "Availability zones for Tomcat cluster"
  default = ["us-east-1a", "us-east-1b"]
}

variable "prod_tomcat_asg_desired" {
  description = "Desired number of servers in tomcat cluster"
  default = 2
}

variable "prod_rabbitmq_asg_min" {
  description = "Minimum number of servers in tomcat cluster"
  default = 1
}

variable "prod_rabbitmq_asg_max" {
  description = "Maximum number of servers in tomcat cluster"
  default = 2
}

variable "prod_rabbitmq_asg_desired" {
  description = "Desired number of servers in tomcat cluster"
  default = 2
}

variable "prod_rabbitmq_asg_azs" {
  description = "Availability zones for Rabbitmq cluster"
  default = ["us-east-1a", "us-east-1b"]
}

variable "prod_mongodb_asg_azs" {
  description = "Availability zones for MongoDB cluster"
  default = ["us-east-1a", "us-east-1b","us-east-1d"]
}
