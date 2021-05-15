#Create a provider
provider "aws" {
  region = "${var.region}"
}

#Create backend s3
terraform {
  backend "s3" {}
}

#Create a remote state to read s3 configurations
data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  
  config {
    region = "${var.region}"
    bucket = "${var.remote_state_bucket}"
    key    = "${var.remote_state_key}"
  }
}

#Inorder to use ALB with subdomain and different targets group we are gonna create a default target group which ecs understands and actual lb can route the trrafic to our subdomains and services we registered down with target groups, This target group not going to do anything, its basically required by aws for any application lb going to create 
resource "aws_alb_target_group" "ecs_default_target_group" {
  name     = "${var.ecs_cluster_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.infrastructure.vpc_id}"
  
  tags = {
    Name = "${var.ecs_cluster_name}-TG"
  }
}

#Create ECS cluster and ALB
resource "aws_ecs_cluster" "production-fargate-cluster" {
  name = "Production-Fargate-Cluster"
}

resource "aws_alb" "ecs_cluster_elb" {
  name           = "${var.ecs_cluster_name}-ALB"
  internal       = false
  security_group = ["${aws_security_group.ecs_alb_security_group.id}"]
  subnets        = ["${split(",", join(",", data.terraform_remote_state.infrastructure.public_subnets))}"]
  
  tags = {
    Name = "${var.ecs_cluster_name}-ALB"
  }
}


#Create route 53 record for load balancer
resource "aws_route53_record" {
  name    = "*.${var.ecs_domain_name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.ecs_domain.zone_id}"
  
  alias {
    evaluate_target_health = false
    name                   = "${aws_alb.ecs_cluster_alb.dns_name}"
    zone_id                = "${aws_alb.ecs_cluster_alb.zone_id}"
  }
}
