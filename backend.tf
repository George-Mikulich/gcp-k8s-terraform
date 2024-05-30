terraform {
  backend "gcs" {
    bucket = "c7ac3f65f0fb3c08-bucket-tfstate"
    prefix = "terraform/state"
  }
}