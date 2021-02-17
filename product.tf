variable "zone_array" {
type    = list(string)
default = ["us-east-2a", "us-east-2b"]
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_s3_bucket" "product_tf_course" {
  bucket = "training-with-terraform-20210215"
  acl    = "private"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-2a"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = "us-east-2b"
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_security_group" "product_web" {
  name        = "product_web"
  description = "Allow http and https (80, 443) port to inbound and everything outboun"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  count = 2

  ami               = "ami-0b520470eb99fa895"
  instance_type     = "t2.micro"
  availability_zone = var.zone_array[count.index]  

  vpc_security_group_ids = [
    aws_security_group.product_web.id
  ]

  tags = {
    "Terraform" : "true"
  }
}

resource "aws_eip_association" "product_web" {
  instance_id   = aws_instance.product_web[0].id
  allocation_id = aws_eip.product_web.id
}

resource "aws_eip" "product_web" {
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_elb" "product_web" {
  name            = "product-web-lb"
  instances       = aws_instance.product_web[*].id
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]  
  security_groups = [aws_security_group.product_web.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags = {
    "Terraform" : "true"
  }
}


