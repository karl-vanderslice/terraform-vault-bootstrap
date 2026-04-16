# terraform-vault-bootstrap

[← docs.vslice.net](https://docs.vslice.net){ .md-button }

Terraform configuration that bootstraps HashiCorp Vault for secret management
workflows.

## What it provisions

- **KV v2 mount** — creates or reuses a KV v2 secrets engine
- **Least-privilege policy** — scoped to configured secret prefixes with
  tunable capabilities
- **Renewable token** — minted and scoped to the created policy
- **AppRole auth** — optional AppRole backend for Kubernetes External Secrets
  Operator integration

## Quick start

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and set `vault_addr`
   and `vault_token`.
2. Copy `managed-credentials.yaml.example` to `managed-credentials.yaml` with
   your credential inventory.
3. Run:

```bash
just format
just lint
just plan
just apply
```

The module is intentionally generic. Policy name, token display name, mount
description, capabilities, and managed prefixes are all configurable without
changing module code.
