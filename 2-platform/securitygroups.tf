resource "aws_security_group" "ecs_alb_security_group" {
  name        = "${var.ecs_cluster_name}-ALB-SG"
  description = "Security group for ALB to traffic for ECS cluster"
  vpc_id      = "${data.terraform_remote_state.infrastructure.vpc_id}"
  
  ingress {
    from_port = 443
    protocol = "TCP"
    to_port = 443
    cidr_blocks = []
  }
}
