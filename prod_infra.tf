# IAM Role
resource "aws_iam_role" "prod-iam-role" {
  name = "prod-iam-role"
  path = "/"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}

# Role policy
resource "aws_iam_role_policy" "prod-iam-role-policy" {
  name = "prod-iam-role"
  role = "${aws_iam_role.prod-iam-role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Action": [
      "*"
    ],
    "Effect": "Allow",
    "Resource": "*"
  }
  ]
}
EOF
}

# Instance Profile
resource "aws_iam_instance_profile" "prod-iam-profile" {
  name = "prod-iam-role"
  roles = ["${aws_iam_role.prod-iam-role.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for Loadbalancer for Web Cluster
resource "aws_security_group" "prod-web" {
  name = "prod_web"
  description = "Allow access to HTTP and HTTPS on loadbalancer"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
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
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.prod.id}"

  tags {
    Name = "WEBSG"
  }
}

# Security group to allow access to all services on private network inside of VPC.
resource "aws_security_group" "prod-internal" {
  name = "prod-internal"
  description = "Allow access internally within VPC"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.prod_vpc_cidr}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.prod.id}"

  tags {
    Name = "INTERNALSG"
  }
}

# Security group for openvpn instance.
resource "aws_security_group" "vpn" {
  name = "vpn"
  description = "Allow access via VPN tunnel"

  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prod-vpn" {
  ami = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.vpn.id}","${aws_security_group.prod-internal.id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
  subnet_id = "${aws_subnet.az1-public.id}"
  user_data = "${file("scripts/userdata_vpn.sh")}"
  associate_public_ip_address = true
  source_dest_check = false
  tags {
    Name = "Production OpenVPN"
  }
}

resource "aws_elb" "prod-tomcat-lb" {
  name = "prod-tomcat-lb"

  subnets = ["${aws_subnet.az1-public.id}","${aws_subnet.az2-public.id}"]
  security_groups = ["${aws_security_group.prod-web.id}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
  cross_zone_load_balancing = true
  tags {
    Name = "prod-tomcat-lb"
  }
}

resource "aws_route53_record" "prod-tomcat-lb" {
  zone_id = "${aws_route53_zone.prod_zone_public.zone_id}"
  name = "foo"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.prod-tomcat-lb.dns_name}"]
}

resource "aws_autoscaling_group" "prod-tomcat-asg" {
  name = "prod-tomcat-asg"
  vpc_zone_identifier = ["${aws_subnet.az1-private.id}","${aws_subnet.az2-private.id}"]
  max_size = "${lookup(var.prod_asgs,"tomcat.max")}"
  min_size = "${lookup(var.prod_asgs,"tomcat.min")}"
  desired_capacity = "${lookup(var.prod_asgs,"tomcat.desired")}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.prod-tomcat-lc.name}"
  load_balancers = ["${aws_elb.prod-tomcat-lb.name}"]
  tag {
    key = "ASG-Name"
    value = "prod-tomcat-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "prod-tomcat-lc" {
  name = "prod-tomcat-lc"
  image_id = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"

  security_groups = ["${aws_security_group.prod-internal.id}"]
  user_data = "${file("scripts/userdata_tomcat.sh")}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
}

resource "aws_elb" "prod-rabbitmq-lb" {
  name = "prod-rabbitmq-lb"

  internal = true
  subnets = ["${aws_subnet.az1-private.id}","${aws_subnet.az2-private.id}"]
  security_groups = ["${aws_security_group.prod-internal.id}"]
  listener {
    instance_port = 5672
    instance_protocol = "tcp"
    lb_port = 5672
    lb_protocol = "tcp"
  }
  listener {
    instance_port = 15672
    instance_protocol = "http"
    lb_port = 15672
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:5672"
    interval = 30
  }
  cross_zone_load_balancing = true
  tags {
    Name = "prod-rabbitmq-lb"
  }
}

resource "aws_route53_record" "prod-rabbitmq-lb" {
  zone_id = "${aws_route53_zone.prod_zone_private.zone_id}"
  name = "rabbitmq"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.prod-rabbitmq-lb.dns_name}"]
}

resource "aws_autoscaling_group" "prod-rabbitmq-asg" {
  name = "prod-rabbitmq-asg"
  vpc_zone_identifier = ["${aws_subnet.az1-private.id}","${aws_subnet.az2-private.id}"]
  max_size = "${lookup(var.prod_asgs,"rabbitmq.max")}"
  min_size = "${lookup(var.prod_asgs,"rabbitmq.min")}"
  desired_capacity = "${lookup(var.prod_asgs,"rabbitmq.desired")}"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.prod-rabbitmq-lc.name}"
  load_balancers = ["${aws_elb.prod-rabbitmq-lb.name}"]
  tag {
    key = "ASG-Name"
    value = "prod-rabbitmq-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "prod-rabbitmq-lc" {
  name = "prod-rabbitmq-lc"
  image_id = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"

  security_groups = ["${aws_security_group.prod-internal.id}"]
  user_data = "${file("scripts/userdata_rabbitmq.sh")}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
}

resource "aws_instance" "mongo-master" {
  ami = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.prod-internal.id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
  subnet_id = "${aws_subnet.az1-private.id}"
  user_data = "${file("scripts/userdata_mongo_master.sh")}"
}

resource "aws_instance" "mongo-slave" {
  ami = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.prod-internal.id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
  subnet_id = "${aws_subnet.az2-private.id}"
  user_data = "${file("scripts/userdata_mongo_slave.sh")}"
}

resource "aws_instance" "mongo-arbiter" {
  ami = "${lookup(var.amis, var.prod_region)}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.prod-internal.id}"]
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
  subnet_id = "${aws_subnet.az3-private.id}"
  user_data = "${file("scripts/userdata_mongo_arbiter.sh")}"
}
