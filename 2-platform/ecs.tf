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
