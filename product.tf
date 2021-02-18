variable "whitelist" {
  type = list(string)
}
variable "web_image_id" {
  type = string
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}

variable "web_zone" {
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
  availability_zone = var.web_zone[0]
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = var.web_zone[1]
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
    cidr_blocks = var.whitelist
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelist
  }
  tags = {
    "Terraform" : "true"
  }
}



resource "aws_elb" "product_web" {
  name            = "product-web-lb"
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

resource "aws_launch_template" "product_web" {
  name_prefix   = "product-web"
  image_id      = var.web_image_id
  instance_type = var.web_instance_type
  vpc_security_group_ids = [ aws_security_group.product_web.id ]
  tags = {
    "Terraform" : "true"
  }
}

resource "aws_autoscaling_group" "product_web" {
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  desired_capacity    = var.web_desired_capacity
  max_size            = var.web_max_size
  min_size            = var.web_min_size
   

  launch_template {
    id      = aws_launch_template.product_web.id
    version = "$Latest"
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_attachment" "product_web" {
  autoscaling_group_name = aws_autoscaling_group.product_web.id
  elb                    = aws_elb.product_web.id
}