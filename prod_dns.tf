resource "aws_route53_zone" "prod_zone_public" {
  name = "${var.prod_route53_zone_public}"
}

resource "aws_route53_zone" "prod_zone_private" {
  name = "${var.prod_route53_zone_private}"
  vpc_id = "${aws_vpc.prod.id}"
}
