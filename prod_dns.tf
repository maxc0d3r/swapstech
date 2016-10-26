resource "aws_route53_zone" "upwork" {
  name = "prod.upwork.org"
  vpc_id = "${aws_vpc.prod.id}"
}
