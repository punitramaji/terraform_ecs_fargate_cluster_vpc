output "vpc_id" {
  value = "${data.terraform_remote_state.infrastructure.vpc_id}"
}

output "vpc_cidr_block" {
  value = "${data.terraform_remote_state.infrastructure.vpc_cidr_block}"
}

output "ecs_alb_listner_arn" {
  value = "${aws_alb_listner.ecs_alb_https_listner.arn}"
}

output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.production-fargate-cluster.name}"
}

