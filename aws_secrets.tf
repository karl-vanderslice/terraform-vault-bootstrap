resource "vault_aws_secret_backend" "aws" {
  path       = "aws"
  access_key = var.vault_iam_access_key_id
  secret_key = var.vault_iam_secret_access_key
  region     = var.aws_region

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}
