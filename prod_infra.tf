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

resource "aws_elb" "prod-tomcat-lb" {
  name = "prod-tomcat-lb"

  subnets = ["${aws_subnet.us-east-1a-public.id}","${aws_subnet.us-east-1b-public.id}"]
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
  zone_id = "${aws_route53_zone.upwork.zone_id}"
  name = "foo.prod.upwork.org"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.prod-tomcat-lb.dns_name}"]
}

resource "aws_autoscaling_group" "prod-tomcat-asg" {
  name = "prod-tomcat-asg"
  vpc_zone_identifier = ["${aws_subnet.us-east-1a-private.id}","${aws_subnet.us-east-1b-private.id}"]
  max_size = "${var.prod_tomcat_asg_max}"
  min_size = "${var.prod_tomcat_asg_min}"
  desired_capacity = "${var.prod_tomcat_asg_desired}"
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
  user_data = "${file("prod_tomcat_userdata.sh")}"
  key_name = "${var.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.prod-iam-profile.id}"
}
