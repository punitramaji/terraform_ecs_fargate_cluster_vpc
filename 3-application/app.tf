provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "platform" {
  backend = "s3"
  
  config = {
    key    = "${var.remote_state_key}"
    bucket = "${var.remote_state_bucket}"
    region = "${var.region}"
  }
}

date "template_file" "ecs_task_defination_template" {
  template = "${file(task_defination.json)}"
  
  vars {
    task_defination_name  = "${var.ecs_service_name}"
    ecs_service_name      = "${var.ecs_service_name}"
    docker_image_url      = "${var.docker_image_url}"
    memory                = "${var.memory}"
    docker_container_port = "${var.docker_container_port}"
    spring_profile        = "${var.spring_profile}"
    region                = "${var.region}"
  }
}

resource "aws_ecs_task_defination" "springbootapp-task-defination" {
  container_defination     = "${data.template_file.ecs_task_defination_template.rendered}"
  family                   = "${var.ecs_service_name}"
  cpu                      = 512
  memory                   = "${var.memory}"
  requires_compatibilities = ["FARGATE"]
  networking_mode          = "awsvpc"
  execution_role_arn       = ""
  task_role_arn            = ""
}

#49 Creating IAM Task and Execution Role and Policy for ECS Tasks
resource "aws_iam_role" "fargate_iam_role" {
  name               = "${var.ecs_service_name}-IAM-Role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
       "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    },
    "Action": "sts:AssumeRole"
  }
  ]
}
EOF
}

resource "aws_iam_role_policy" "fargate_iam_role_policy" {
  name = "${var.ecs_service_name}-IAM-Role-Policy"
  role = "${aws_iam_role.fargate_iam_role.id}"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*",
      ],
      "Resource" "*"
     }
  ]
}
EOF
}

#50 Creating Security Group for ECS Service
resource "aws_security_group" "app_security_group" {
  name        = "${var.ecs_service_name}-SG"
  description = "Security group for springbootapp to communicate in and out"
  vpc_id      = "${data.terraform_remote_state.platform.vpc_id}"
  
  ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8080
    cidr_blocks = ["${data.terraform_remote_state.platform.vpc_cidr_blocks}"]
  }
  
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "${var.ecs_service_name}-SG"
  }
}

#51 Creating ALB Target Group for ECS Service
resource "aws_alb_target_group" "ecs_app_target_group" {
  name        = "${var.ecs_service_name}-TG"
  port        = "${var.docker_container_port}"
  protocol    = "HTTP"
  vpc_id      = "${data.terraform_remote_state.platform.vpc_id}"
  target_type = "ip"
  
  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }
  
  tags = {
    Name = "${var.ecs_service_name}-TG"
  }
}

#52 Creating ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.ecs_service_name}"
  task_defination = "${var.ecs_service_name}"
  desired_count   = "${var.desired_task_number}"
  cluster         = "${data.terraform_remote_state.platform.ecs_cluster_name}"
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = ["${data.terraform_remote_state.platform.ecs_public_subnets}"]
    security_groups  = ["${aws_security_group.app_security_group.id}"]
    assign_public_ip = true
  }
  
  load_balancer {
    container_name   = "${var.ecs_service_name}"
    container_port   = "${var.docker_container_port}"
    target_group_arn = "${aws_alb_target_group.ecs_app_target_group.arn}"
  }
}

#53 Creating ALB Listener Rule for ECS Service
resource "aws_alb_listner_rule" "ecs_alb_listner_rule" {
  listner_arn = "${data.terraform_remote_state.platform.ecs_alb_listner_arn}"
  
  "action" {
    type             = "farward"
    target_group_arn = "${aws_alb_target_group.ecs_app_target_group.arn}"
  }
  
  "condition" {
    field  = "host-header"
    values = ["${lower(var.ecs_service_name)}.${data.terraform_remote_state.platform.ecs_domain_name}"]
  }
}

#54 Creating CloudWatch Log Group for ECS Service
resource "aws_cloudwatch_log_group" "apringbootapp_log_group" {
  name = "${var.ecs_service_name}-LogGroup"
}
