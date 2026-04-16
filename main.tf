locals {
  kv_mount_path                 = trim(var.mcp_kv_mount_path, "/")
  managed_prefixes              = distinct([for p in var.managed_secret_prefixes : trim(p, "/") if trim(p, "/") != ""])
  mcp_mounts_path               = "sys/mounts"
  mcp_health_path               = "sys/health"
  managed_credentials_manifest  = "${path.module}/${var.managed_credentials_manifest_file}"
  managed_credentials_inventory = fileexists(local.managed_credentials_manifest) ? yamldecode(file(local.managed_credentials_manifest)) : { credentials = [] }
}

resource "vault_mount" "mcp_kv" {
  count       = var.create_kv_mount ? 1 : 0
  path        = local.kv_mount_path
  type        = "kv-v2"
  description = var.mcp_kv_mount_description
}

resource "vault_policy" "mcp" {
  name = var.mcp_policy_name

  policy = join(
    "\n\n",
    concat(
      [
        <<-EOT
          path "${local.mcp_mounts_path}" {
            capabilities = ["read", "list"]
          }
        EOT
        ,
        <<-EOT
          path "${local.mcp_health_path}" {
            capabilities = ["read"]
          }
        EOT
      ],
      [
        for prefix in local.managed_prefixes : <<-EOT
          path "${local.kv_mount_path}/data/${prefix}/*" {
            capabilities = ${jsonencode(var.mcp_data_capabilities)}
          }

          path "${local.kv_mount_path}/metadata/${prefix}/*" {
            capabilities = ${jsonencode(var.mcp_metadata_capabilities)}
          }
        EOT
      ]
    )
  )
}

resource "vault_token" "mcp" {
  display_name     = var.mcp_token_display_name
  policies         = [vault_policy.mcp.name]
  renewable        = true
  ttl              = var.mcp_token_ttl
  explicit_max_ttl = var.mcp_token_explicit_max_ttl
  no_parent        = false
}
