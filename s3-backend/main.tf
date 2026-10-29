resource "aws_s3_bucket" "tf_state_bucket" {
  bucket = "my-tf-state-bucket-himanshu2oo4-zerotrustproject"

  tags = {
    Name        = "Tf state bucket"
    Environment = "prod"
  }
}
