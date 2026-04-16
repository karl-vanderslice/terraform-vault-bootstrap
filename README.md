# terraform-vault-bootstrap

Bootstrap repository for Vault-side MCP credentials and policy scaffolding.

This repository configures HashiCorp Vault (including HCP Vault) for generic
MCP workflows by:

- creating (or reusing) a KV v2 mount for MCP-managed secrets
- creating a least-privilege Vault policy across one or more managed secret
  prefixes
- minting a renewable token scoped to that policy

Remote state is stored in HCP Terraform workspace `terraform-vault-bootstrap`
under organization `karl-vanderslice-org`.

The module is intentionally generic. You can tune policy name, token display
name, mount description, capabilities, and managed prefixes without changing
module code.

## Prerequisites

- `just` and `nix` installed
- reachable Vault cluster
- bootstrap Vault admin token

## Quickstart

1. Prepare inputs:

```bash
cp terraform.tfvars.example terraform.tfvars
cp managed-credentials.yaml.example managed-credentials.yaml
```

1. Set real values for `vault_addr` and `vault_token` in
   `terraform.tfvars`.

1. Update `managed-credentials.yaml` with the credential inventory you intend
   to manage. This file is gitignored by design.

1. Authenticate Terraform CLI (`TFE_TOKEN` or `terraform login`) and run:

```bash
just format
just lint
just plan
just apply
```

1. Capture outputs:

```bash
terraform output -json
```

Store `mcp_token` in Bitwarden shared org collection (`ai-sandbox` /
`AI_Shared`) and hydrate into agent-hub as `VAULT_TOKEN`.

## Non-committed credential inventory

Keep the live credential list in `managed-credentials.yaml` (untracked). Keep
the template in `managed-credentials.yaml.example` committed.

The module emits this inventory via output `managed_credentials_inventory` when
the local file exists.

This gives you both:

- explicit inventory of managed credentials
- no secret inventory drift committed to git

## Integration with agent-hub Vault MCP

agent-hub expects:

- `VAULT_ADDR`
- `VAULT_TOKEN`
- `VAULT_NAMESPACE`

If you use the default item name in agent-hub (`HCP Vault Ezra`), set fields:

- `VAULT_ADDR`
- `VAULT_TOKEN`
- `VAULT_NAMESPACE`

Then run from agent-hub:

```bash
just bw-vault-credentials-pull
just mcp-enable vault
just mcp-up
```
