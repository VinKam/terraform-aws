provider "aws" {
  region = "us-east-2"
  profile = "backend"
}

resource "aws_s3_bucket" "backend" {
  bucket = "terraform-aws-backend-vk"
  force_destroy = true
  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "backend" {
  name = "terraform-aws-backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
