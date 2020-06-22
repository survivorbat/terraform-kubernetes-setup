terraform {
  backend "s3" {
    bucket = "example-terraform-state-dev"
    key = "terraform-state.tfstate"
    access_key = "__doAccessKey__"
    secret_key = "__doSecretKey__"
    endpoint = "https://ams3.digitaloceanspaces.com"
    region = "eu-west-1"
    skip_credentials_validation = true
    skip_get_ec2_platforms = true
    skip_requesting_account_id = true
    skip_metadata_api_check = true
  }
}
