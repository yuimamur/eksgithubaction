terraform {
  backend "s3" {
    bucket         = "tfstatetry"
    key            = "eks/terraform.tfstate"
    region         = "us-west-2"
    //dynamodb_table = "tftable"   # Optional, for state locking
    encrypt        = true
  }
}