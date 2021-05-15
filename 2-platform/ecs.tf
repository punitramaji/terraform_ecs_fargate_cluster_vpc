provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  
  config {
    region = "${var.region}"
    bucket = "${}"
  }
}
