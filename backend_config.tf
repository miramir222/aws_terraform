terraform {
  backend "s3" {
    bucket = "github-action-bucket-demo101"
    key    = "github-actions-demo.tfstate"
    region = "ap-south-1"
  }
}