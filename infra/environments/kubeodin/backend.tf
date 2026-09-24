terraform {
  backend "s3" {
    bucket       = "kubeodin-infra-state"
    key          = "kubeodin/terraform.tfstate"
    region       = "ap-south-1"
    profile      = "aws-kubeodin"
    use_lockfile = true
  }
}
