provide "aws {
  profile = "default"
  region = "us-east-2a"
}

resource "aws_s3_bucket" "tf_course" {
  bucket = "traning-with-terraform-20210215"
  acl    = "private"
}
