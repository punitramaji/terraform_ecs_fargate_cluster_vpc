variable "region" {
  default = "eu-west-1"
}

variable "remote_state_key" {}
variable "remote_state_bucket" {}
variable "ecs_service_name" {}
variable "memory" {}
variable "docker_container_port" {}
variable "spring_profile" {}
variable "desired_task_number" {}
