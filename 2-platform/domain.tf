#Create domain certificates that we are using with load balancer of clutser and add validation
#domain name starts with * is because we use same domain for our subdomain also
resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"
  
  tags = {
    Name = "${var.ecs_cluster_name}-Certificate"
  }
}
