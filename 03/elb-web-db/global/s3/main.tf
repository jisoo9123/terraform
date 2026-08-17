provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "myTFState" {
  bucket = "bucket-pjs-0213"
  force_destroy = true

  tags = {
    Name        = "myTFState"
  }
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.myTFState.arn
}


