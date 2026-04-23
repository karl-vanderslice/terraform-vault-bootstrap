# terraform-vault-bootstrap

Bootstrap repository for Vault-side credentials and policy scaffolding.

This repository configures HashiCorp Vault (including HCP Vault) for generic
secret management workflows by:

- creating (or reusing) a KV v2 mount for managed secrets
- creating a least-privilege Vault policy across one or more managed secret
  prefixes
- minting a renewable token scoped to that policy

Remote state can be stored in an HCP Terraform workspace. Configure the `cloud`
backend block in `terraform.tf` with your organization and workspace name.

The module is intentionally generic. You can tune policy name, token display
name, mount description, capabilities, and managed prefixes without changing
module code.

## Prerequisites

- `just` and `nix` installed
- Reachable Vault cluster
- Bootstrap Vault admin token

## Quickstart

1. Prepare inputs:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp managed-credentials.yaml.example managed-credentials.yaml
   ```

2. Set real values for `vault_addr` and `vault_token` in
   `terraform.tfvars`.

3. Update `managed-credentials.yaml` with the credential inventory you intend
   to manage. This file is gitignored by design.

4. Authenticate Terraform CLI (`TFE_TOKEN` or `terraform login`) and run:

   ```bash
   just format
   just lint
   just plan
   just apply
   ```

5. Capture outputs:

   ```bash
   terraform output -json
   ```

   Store sensitive outputs (tokens, role IDs, secret IDs) in your secret manager.

For Kubernetes External Secrets Operator integration, persist the following
outputs:

- `vault_addr` -> `VAULT_ADDR`
- `vault_namespace` -> `VAULT_NAMESPACE`
- `temporary_bootstrap_token`
- `vault_sync_role_id` -> `VAULT_SYNC_ROLE_ID`
- `vault_sync_secret_id` -> `VAULT_SYNC_SECRET_ID`
- `vault_auth_mount_name` -> `VAULT_AUTH_MOUNT`
- `vault_kv_mount_name` -> `VAULT_KV_MOUNT`
- `vault_eso_role_name` -> `VAULT_ESO_ROLE`
- `vault_ca_bundle_or_note`

## Non-committed credential inventory

Keep the live credential list in `managed-credentials.yaml` (untracked). Keep
the template in `managed-credentials.yaml.example` committed.

The module emits this inventory via output `managed_credentials_inventory` when
the local file exists.

This gives you both:

- explicit inventory of managed credentials
- no secret inventory drift committed to git

## Downstream Integration

Downstream consumers that use this Vault configuration need:

- `VAULT_ADDR`
- `VAULT_TOKEN`
- `VAULT_NAMESPACE`

Set these environment variables or store them in your secret manager, then
configure your tooling to read them at runtime.

## OCI GitHub Runner Broker

For [terraform-oci-github-runner](/home/karl/Projects/src/github.com/karl-vanderslice/terraform-oci-github-runner/README.md), use this repo's KV mount as the broker for both GitHub and OCI credential material.

Recommended settings:

- include `github` and `oci` in `managed_secret_prefixes`
- keep the mount path at `mcp-kv` unless you already standardized on another KV v2 mount

Recommended secret layout:

- `mcp-kv/data/github/runner-bootstrap`
  - field `GITHUB_TOKEN`
- `mcp-kv/data/oci/terraform-runner`
  - field `OCI_USER_OCID`
  - field `OCI_TENANCY_OCID`
  - field `OCI_FINGERPRINT`
  - field `OCI_REGION`
  - field `OCI_PRIVATE_KEY`
  - field `OCI_PUBLIC_KEY`

How these are used:

- the OCI runner VM reads `github/runner-bootstrap` at boot in `vault-oci-auth` mode so the long-lived GitHub bootstrap credential never lands in Terraform state
- operator and HCP Terraform workflows can hydrate OCI provider credentials from `oci/terraform-runner` without committing local secret material into the repo

This bootstrap repo does not write those secrets into Vault for you. Keep them external to Terraform state and place them in Vault through your secret-management workflow after the mount and policies exist.

## Terraform Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~> 4.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | 4.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [vault_approle_auth_backend_role.vault_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/approle_auth_backend_role) | resource |
| [vault_approle_auth_backend_role_secret_id.vault_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/approle_auth_backend_role_secret_id) | resource |
| [vault_auth_backend.approle](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/auth_backend) | resource |
| [vault_mount.mcp_kv](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_policy.mcp](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_policy.vault_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_token.mcp](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token) | resource |
| [vault_token.vault_sync_bootstrap](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_kv_mount"></a> [create\_kv\_mount](#input\_create\_kv\_mount) | Whether to create the KV mount for MCP workflows. | `bool` | `true` | no |
| <a name="input_create_vault_auth_mount"></a> [create\_vault\_auth\_mount](#input\_create\_vault\_auth\_mount) | Whether to create the auth mount used for ESO AppRole auth. | `bool` | `true` | no |
| <a name="input_managed_credentials_manifest_file"></a> [managed\_credentials\_manifest\_file](#input\_managed\_credentials\_manifest\_file) | Local, untracked YAML manifest of credentials this repo manages. | `string` | `"managed-credentials.yaml"` | no |
| <a name="input_managed_secret_prefixes"></a> [managed\_secret\_prefixes](#input\_managed\_secret\_prefixes) | KV v2 logical prefixes managed by this bootstrap policy. | `list(string)` | <pre>[<br/>  "ezra"<br/>]</pre> | no |
| <a name="input_mcp_data_capabilities"></a> [mcp\_data\_capabilities](#input\_mcp\_data\_capabilities) | Capabilities granted on KV data paths. | `list(string)` | <pre>[<br/>  "create",<br/>  "read",<br/>  "update",<br/>  "delete",<br/>  "list"<br/>]</pre> | no |
| <a name="input_mcp_kv_mount_description"></a> [mcp\_kv\_mount\_description](#input\_mcp\_kv\_mount\_description) | Description for the KV v2 mount used by MCP workflows. | `string` | `"KV v2 mount for MCP workflows"` | no |
| <a name="input_mcp_kv_mount_path"></a> [mcp\_kv\_mount\_path](#input\_mcp\_kv\_mount\_path) | Path for the KV v2 mount used by MCP workflows. | `string` | `"mcp-kv"` | no |
| <a name="input_mcp_metadata_capabilities"></a> [mcp\_metadata\_capabilities](#input\_mcp\_metadata\_capabilities) | Capabilities granted on KV metadata paths. | `list(string)` | <pre>[<br/>  "read",<br/>  "list",<br/>  "delete"<br/>]</pre> | no |
| <a name="input_mcp_policy_name"></a> [mcp\_policy\_name](#input\_mcp\_policy\_name) | Vault policy name granted to the minted MCP token. | `string` | `"mcp-bootstrap"` | no |
| <a name="input_mcp_token_display_name"></a> [mcp\_token\_display\_name](#input\_mcp\_token\_display\_name) | Display name for the minted Vault token. | `string` | `"mcp-bootstrap"` | no |
| <a name="input_mcp_token_explicit_max_ttl"></a> [mcp\_token\_explicit\_max\_ttl](#input\_mcp\_token\_explicit\_max\_ttl) | Maximum non-renewable lifetime for minted token. | `string` | `"168h"` | no |
| <a name="input_mcp_token_ttl"></a> [mcp\_token\_ttl](#input\_mcp\_token\_ttl) | TTL for the minted Ezra MCP token. | `string` | `"24h"` | no |
| <a name="input_vault_addr"></a> [vault\_addr](#input\_vault\_addr) | Vault API address (for HCP Vault this is the public cluster URL). | `string` | n/a | yes |
| <a name="input_vault_auth_mount_description"></a> [vault\_auth\_mount\_description](#input\_vault\_auth\_mount\_description) | Description for the ESO AppRole auth mount. | `string` | `"AppRole auth mount for Kubernetes external-secrets sync"` | no |
| <a name="input_vault_auth_mount_path"></a> [vault\_auth\_mount\_path](#input\_vault\_auth\_mount\_path) | Auth mount path used for ESO AppRole auth. | `string` | `"approle"` | no |
| <a name="input_vault_eso_policy_name"></a> [vault\_eso\_policy\_name](#input\_vault\_eso\_policy\_name) | Vault policy name used by ESO AppRole and bootstrap token. | `string` | `"vault-sync-read"` | no |
| <a name="input_vault_eso_role_name"></a> [vault\_eso\_role\_name](#input\_vault\_eso\_role\_name) | Vault AppRole name used by Kubernetes External Secrets Operator. | `string` | `"external-secrets-operator"` | no |
| <a name="input_vault_namespace"></a> [vault\_namespace](#input\_vault\_namespace) | Vault namespace (HCP Vault default is admin). | `string` | `"admin"` | no |
| <a name="input_vault_sync_bootstrap_token_display_name"></a> [vault\_sync\_bootstrap\_token\_display\_name](#input\_vault\_sync\_bootstrap\_token\_display\_name) | Display name for short-lived bootstrap token used during ESO setup. | `string` | `"vault-sync-bootstrap"` | no |
| <a name="input_vault_sync_bootstrap_token_max_ttl"></a> [vault\_sync\_bootstrap\_token\_max\_ttl](#input\_vault\_sync\_bootstrap\_token\_max\_ttl) | Maximum TTL for short-lived bootstrap token used during ESO setup. | `string` | `"2h"` | no |
| <a name="input_vault_sync_bootstrap_token_ttl"></a> [vault\_sync\_bootstrap\_token\_ttl](#input\_vault\_sync\_bootstrap\_token\_ttl) | TTL for short-lived bootstrap token used during ESO setup. | `string` | `"30m"` | no |
| <a name="input_vault_sync_secret_id_ttl"></a> [vault\_sync\_secret\_id\_ttl](#input\_vault\_sync\_secret\_id\_ttl) | TTL in seconds for generated AppRole secret IDs used by ESO. | `number` | `86400` | no |
| <a name="input_vault_sync_token_max_ttl"></a> [vault\_sync\_token\_max\_ttl](#input\_vault\_sync\_token\_max\_ttl) | Maximum token TTL in seconds for Vault AppRole logins used by ESO. | `number` | `86400` | no |
| <a name="input_vault_sync_token_ttl"></a> [vault\_sync\_token\_ttl](#input\_vault\_sync\_token\_ttl) | Default token TTL in seconds for Vault AppRole logins used by ESO. | `number` | `3600` | no |
| <a name="input_vault_token"></a> [vault\_token](#input\_vault\_token) | Bootstrap admin token used to configure Vault. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_managed_credentials_inventory"></a> [managed\_credentials\_inventory](#output\_managed\_credentials\_inventory) | Local credential inventory loaded from managed-credentials.yaml when present. |
| <a name="output_managed_secret_prefixes"></a> [managed\_secret\_prefixes](#output\_managed\_secret\_prefixes) | KV prefixes included in the generated MCP policy. |
| <a name="output_mcp_kv_mount_path"></a> [mcp\_kv\_mount\_path](#output\_mcp\_kv\_mount\_path) | Mounted KV path for MCP workflows. |
| <a name="output_mcp_policy_name"></a> [mcp\_policy\_name](#output\_mcp\_policy\_name) | Policy granted to the minted MCP token. |
| <a name="output_mcp_token"></a> [mcp\_token](#output\_mcp\_token) | Minted Vault token for MCP workflows. Store in Bitwarden immediately. |
| <a name="output_mcp_token_id"></a> [mcp\_token\_id](#output\_mcp\_token\_id) | Token id for auditing or revocation workflows. |
| <a name="output_temporary_bootstrap_token"></a> [temporary\_bootstrap\_token](#output\_temporary\_bootstrap\_token) | Short-lived token for bootstrap/testing during ESO onboarding. |
| <a name="output_vault_addr"></a> [vault\_addr](#output\_vault\_addr) | Vault address to configure MCP clients. |
| <a name="output_vault_auth_mount_name"></a> [vault\_auth\_mount\_name](#output\_vault\_auth\_mount\_name) | Vault auth mount used for AppRole-based ESO authentication. |
| <a name="output_vault_ca_bundle_or_note"></a> [vault\_ca\_bundle\_or\_note](#output\_vault\_ca\_bundle\_or\_note) | CA bundle guidance for ESO Vault connectivity. |
| <a name="output_vault_eso_role_name"></a> [vault\_eso\_role\_name](#output\_vault\_eso\_role\_name) | Vault AppRole name for External Secrets Operator. |
| <a name="output_vault_kv_mount_name"></a> [vault\_kv\_mount\_name](#output\_vault\_kv\_mount\_name) | Vault KV mount used by ESO sync policy. |
| <a name="output_vault_namespace"></a> [vault\_namespace](#output\_vault\_namespace) | Vault namespace for MCP clients. |
| <a name="output_vault_sync_role_id"></a> [vault\_sync\_role\_id](#output\_vault\_sync\_role\_id) | Vault AppRole role\_id for External Secrets Operator. |
| <a name="output_vault_sync_secret_id"></a> [vault\_sync\_secret\_id](#output\_vault\_sync\_secret\_id) | Fresh Vault AppRole secret\_id for External Secrets Operator. |
<!-- END_TF_DOCS -->
