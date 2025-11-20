terraform {
  backend "s3" {
    bucket         = "r10score-terraform-state-dev"
    key            = "poc_observabilitydev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "r10score-terraform-state-dev-locks"
    encrypt        = true
  }
}

