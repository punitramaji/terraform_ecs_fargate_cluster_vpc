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
  cidr_block        = "${var.public_subnet_1_cidr}"
  vpc_id            = "${aws_vpc.production-vpc.id}"
  availability_zone = "eu-west-1a"
  
  tags {
    Name = "Public-Subnet-1"
  }
}
