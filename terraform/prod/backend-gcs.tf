terraform {
  backend "gcs" {
    bucket  = "tf-state-vb"
    path    = "terraform-prod.tfstate"
    project = "infra-179411"
  }
}
