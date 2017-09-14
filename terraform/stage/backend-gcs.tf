terraform {
  backend "gcs" {
    bucket  = "tf-state-vb"
    path    = "terraform-stage.tfstate"
    project = "infra-179411"
  }
}
