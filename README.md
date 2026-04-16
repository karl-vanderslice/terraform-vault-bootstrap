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
