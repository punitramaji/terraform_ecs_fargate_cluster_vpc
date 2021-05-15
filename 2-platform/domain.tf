#Create domain certificates that we are using with load balancer of clutser and add validation
#domain name starts with * is because we use same domain for our subdomain also
resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"
  
  tags = {
    Name = "${var.ecs_cluster_name}-Certificate"
  }
}

data "aws_route53_zone" "ecs_domain" {
  name         = "${var.ecs_domain_name}"
  private_zone = false
}

resource "aws_route53_record" "ecs_cert_validation_record" {
  name            = "${aws_acm_certificate.ecs_domain_certificate.domain_validation_options.0.resource_record_name}"
  type            = "${aws_acm_certificate.ecs_domain_certificate.domain_validation_options.0.resource_record_type}"
  zone_id         = "${data.aws_route53_zone.ecs_domain.zone_id}"
  records         = ["${aws_acm_cretificate.ecs_domain_certificate.domain_validation_options.0.resource_record_value}"]
  ttl             = 60
  allow_overwrite = true
}
