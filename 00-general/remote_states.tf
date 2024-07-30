data "terraform_remote_state" "github" {
  backend = "s3"
  config = {
    bucket         = "terraform-remote-state-vault"
    key            = "github/PRO/github-pro.tfstate"
    region         = "eu-west-1"
  }
}
