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

output "vault_auth_mount_name" {
  description = "Vault auth mount used for AppRole-based ESO authentication."
  value       = local.vault_auth_mount_path
}

output "vault_kv_mount_name" {
  description = "Vault KV mount used by ESO sync policy."
  value       = local.kv_mount_path
}

output "vault_eso_role_name" {
  description = "Vault AppRole name for External Secrets Operator."
  value       = vault_approle_auth_backend_role.vault_sync.role_name
}

output "vault_sync_role_id" {
  description = "Vault AppRole role_id for External Secrets Operator."
  value       = vault_approle_auth_backend_role.vault_sync.role_id
  sensitive   = true
}

output "vault_sync_secret_id" {
  description = "Fresh Vault AppRole secret_id for External Secrets Operator."
  value       = vault_approle_auth_backend_role_secret_id.vault_sync.secret_id
  sensitive   = true
}

output "temporary_bootstrap_token" {
  description = "Short-lived token for bootstrap/testing during ESO onboarding."
  value       = vault_token.vault_sync_bootstrap.client_token
  sensitive   = true
}

output "vault_ca_bundle_or_note" {
  description = "CA bundle guidance for ESO Vault connectivity."
  value       = "Public CA is sufficient for the HCP Vault public endpoint; no custom CA bundle required."
}

output "admin_automation_role_name" {
  description = "Vault AppRole name for admin automation access."
  value       = var.create_admin_automation_role ? vault_approle_auth_backend_role.admin_automation[0].role_name : null
}

output "admin_automation_role_id" {
  description = "Vault AppRole role_id for admin automation access."
  value       = var.create_admin_automation_role ? vault_approle_auth_backend_role.admin_automation[0].role_id : null
  sensitive   = true
}

output "admin_automation_secret_id" {
  description = "Fresh Vault AppRole secret_id for admin automation access."
  value       = var.create_admin_automation_role ? vault_approle_auth_backend_role_secret_id.admin_automation[0].secret_id : null
  sensitive   = true
}

output "admin_automation_token" {
  description = "Renewable admin-scoped automation token. Store in Bitwarden immediately."
  value       = var.create_admin_automation_token ? vault_token.admin_automation[0].client_token : null
  sensitive   = true
}
