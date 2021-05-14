provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {}
}

resource "aws_vpc" "production-vpc" {
  cidr_block          = "${var.vpc_cidr}"
  enable_dns_hostname = true
  
  tags {
    name = "Production-vpc"
  }
}

resource "aws_subnet" "" {
  cidr_block = ""
  vpc_id     = "${var.vpc.production-vpc.id}"
}
