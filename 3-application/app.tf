provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "platform" {
  backend = "s3"
  
  config = {
    key = "${var.remote_state_key}"
  }
}
