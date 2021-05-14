variable "region" {
  default     = "eu-west-1"
  description = "AWS-Region"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
}

variable "public_subnet_1_cidr" {
  description = "Public Subnet 1 CIDR"
}
