variable "asgs" {
  type = "map"
  default = {
    tomcat.min = 0,
    tomcat.max = 2,
    tomcat.desired = 1,
    rabbitmq.min = 0,
    rabbitmq.max = 2,
    rabbitmq.desired = 2
  }
}

variable "instance_type" {
  type = "map"
  default = {
    tomcat = "t2.micro",
    rabbitmq = "t2.micro"
    mongo-master = "t2.micro"
    mongo-slave = "t2.micro"
    mongo-arbiter = "t2.micro"
    vpn = "t2.micro"
    nat = "t2.micro"
  }
}

variable "tomcat_lb_name" {
  default = "web"
}

variable "rabbitmq_lb_name" {
  default = "amqp"
}
