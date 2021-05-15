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

resource "aws_acm_certificate_validation" "ecs_domain_certificate_validation" {
  certificate_arn = "${aws_acm_certificate.ecs_domain_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.ecs_cert_validation_record.fqdn}"]
}

#Create a IAM role, this will help us to access other aws services, s3 bucket, autoscale our cluster or anyother thing
resource "aws_iam_role" "ecs_cluster_role" {
  name = "${var.ecs_cluster_name}-IAM-Role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": ["ecs.amazon.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
     },
     "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}
