terraform {
  backend "s3" {
    bucket = "terraform-state-guilherme2907"
    key    = "Prod/terraform.tfstate"
    region = "sa-east-1"
  }
}
