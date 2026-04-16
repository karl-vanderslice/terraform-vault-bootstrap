output "vault_addr" {
  description = "Vault address to configure MCP clients."
  value       = var.vault_addr
}

output "vault_namespace" {
  description = "Vault namespace for MCP clients."
  value       = var.vault_namespace
}

output "mcp_kv_mount_path" {
  description = "Mounted KV path for MCP workflows."
  value       = local.kv_mount_path
}

output "managed_secret_prefixes" {
  description = "KV prefixes included in the generated MCP policy."
  value       = local.managed_prefixes
}

output "mcp_policy_name" {
  description = "Policy granted to the minted MCP token."
  value       = vault_policy.mcp.name
}

output "mcp_token" {
  description = "Minted Vault token for MCP workflows. Store in Bitwarden immediately."
  value       = vault_token.mcp.client_token
  sensitive   = true
}

output "mcp_token_id" {
  description = "Token id for auditing or revocation workflows."
  value       = vault_token.mcp.id
  sensitive   = true
}

output "managed_credentials_inventory" {
  description = "Local credential inventory loaded from managed-credentials.yaml when present."
  value       = local.managed_credentials_inventory
}
