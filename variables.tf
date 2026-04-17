variable "vault_addr" {
  description = "Vault API address (for HCP Vault this is the public cluster URL)."
  type        = string
}

variable "vault_iam_access_key_id" {
  description = "AWS access key ID for the Vault IAM user (from terraform-aws-bootstrap)."
  type        = string
}

variable "vault_iam_secret_access_key" {
  description = "AWS secret access key for the Vault IAM user (from terraform-aws-bootstrap)."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for the Vault AWS secrets engine."
  type        = string
  default     = "us-east-1"
}

variable "vault_token" {
  description = "Bootstrap admin token used to configure Vault."
  type        = string
  sensitive   = true
}

variable "vault_namespace" {
  description = "Vault namespace (HCP Vault default is admin)."
  type        = string
  default     = "admin"
}

variable "mcp_kv_mount_path" {
  description = "Path for the KV v2 mount used by MCP workflows."
  type        = string
  default     = "mcp-kv"
}

variable "mcp_kv_mount_description" {
  description = "Description for the KV v2 mount used by MCP workflows."
  type        = string
  default     = "KV v2 mount for MCP workflows"
}

variable "create_kv_mount" {
  description = "Whether to create the KV mount for MCP workflows."
  type        = bool
  default     = true
}

variable "mcp_policy_name" {
  description = "Vault policy name granted to the minted MCP token."
  type        = string
  default     = "mcp-bootstrap"
}

variable "mcp_token_display_name" {
  description = "Display name for the minted Vault token."
  type        = string
  default     = "mcp-bootstrap"
}

variable "mcp_token_ttl" {
  description = "TTL for the minted Ezra MCP token."
  type        = string
  default     = "24h"
}

variable "mcp_token_explicit_max_ttl" {
  description = "Maximum non-renewable lifetime for minted token."
  type        = string
  default     = "168h"
}

variable "managed_secret_prefixes" {
  description = "KV v2 logical prefixes managed by this bootstrap policy."
  type        = list(string)
  default     = ["ezra"]
}

variable "mcp_data_capabilities" {
  description = "Capabilities granted on KV data paths."
  type        = list(string)
  default     = ["create", "read", "update", "delete", "list"]
}

variable "mcp_metadata_capabilities" {
  description = "Capabilities granted on KV metadata paths."
  type        = list(string)
  default     = ["read", "list", "delete"]
}

variable "managed_credentials_manifest_file" {
  description = "Local, untracked YAML manifest of credentials this repo manages."
  type        = string
  default     = "managed-credentials.yaml"
}

variable "create_vault_auth_mount" {
  description = "Whether to create the auth mount used for ESO AppRole auth."
  type        = bool
  default     = true
}

variable "vault_auth_mount_path" {
  description = "Auth mount path used for ESO AppRole auth."
  type        = string
  default     = "approle"
}

variable "vault_auth_mount_description" {
  description = "Description for the ESO AppRole auth mount."
  type        = string
  default     = "AppRole auth mount for Kubernetes external-secrets sync"
}

variable "vault_eso_policy_name" {
  description = "Vault policy name used by ESO AppRole and bootstrap token."
  type        = string
  default     = "vault-sync-read"
}

variable "vault_eso_role_name" {
  description = "Vault AppRole name used by Kubernetes External Secrets Operator."
  type        = string
  default     = "external-secrets-operator"
}

variable "vault_sync_token_ttl" {
  description = "Default token TTL in seconds for Vault AppRole logins used by ESO."
  type        = number
  default     = 3600
}

variable "vault_sync_token_max_ttl" {
  description = "Maximum token TTL in seconds for Vault AppRole logins used by ESO."
  type        = number
  default     = 86400
}

variable "vault_sync_secret_id_ttl" {
  description = "TTL in seconds for generated AppRole secret IDs used by ESO."
  type        = number
  default     = 86400
}

variable "vault_sync_bootstrap_token_display_name" {
  description = "Display name for short-lived bootstrap token used during ESO setup."
  type        = string
  default     = "vault-sync-bootstrap"
}

variable "vault_sync_bootstrap_token_ttl" {
  description = "TTL for short-lived bootstrap token used during ESO setup."
  type        = string
  default     = "30m"
}

variable "vault_sync_bootstrap_token_max_ttl" {
  description = "Maximum TTL for short-lived bootstrap token used during ESO setup."
  type        = string
  default     = "2h"
}
