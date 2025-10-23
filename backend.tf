terraform {
  backend "s3" {
    bucket = "yuya-test-1023"
    key    = "eks/terraform.tfstate"
    region = "us-east-2"
    //dynamodb_table = "tftable"   # Optional, for state locking
    encrypt = true
  }
}