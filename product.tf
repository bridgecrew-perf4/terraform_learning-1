provider "aws" {
  profile = "default"
  region = "us-east-2"
}

resource "aws_s3_bucket" "product_tf_course" {
  bucket = "training-with-terraform-20210215"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "product_web" {
  name = "product_web"
  description = "Allow http and https (80, 443) port to inbound and everything outboun"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["178.121.42.99/32"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["178.121.42.99/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" : "true"
  }
}


resource "aws_instance" "product_web" {
  ami           = "ami-0b520470eb99fa895"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.product_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_eip" "product_web" {
  instance = aws_instance.product_web.id

  tags = {
    "Terraform" : "true"
  }
}

