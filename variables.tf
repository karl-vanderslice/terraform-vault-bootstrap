variable "vault_addr" {
  description = "Vault API address (for HCP Vault this is the public cluster URL)."
  type        = string
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
