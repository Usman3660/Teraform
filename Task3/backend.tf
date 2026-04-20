terraform {
  backend "s3" {
    bucket         = "assignment3-tfstate-5f1518db"
    key            = "task3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "assignment3-terraform-locks"
    encrypt        = true
  }
}
