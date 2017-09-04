terraform {
  backend "s3" {
    bucket         = "therasec-state-bucket"
    region         = "us-east-1"
    encrypt        = "true"
    acl            = "private"
    dynamodb_table = "therasec-state-bucket"
    profile        = "therasec-prod"
  }
}

variable "environment" {}
variable "vpc_id" {}
variable "port" {}

provider "aws" {
  profile = "${var.environment}"
  region  = "us-east-1"
}

resource "aws_security_group" "sg" {
  name = "test"
  description = "test security group"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.port}"
    to_port     = "${var.port}"
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.1/32"]
  }
}

output "id" {
  value = "${aws_security_group.sg.id}"
}
