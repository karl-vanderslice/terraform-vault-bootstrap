# AGENTS

## Purpose

This repository bootstraps Vault-side credentials, policies, and related
platform scaffolding.

## Documentation Standards

- Keep `README.md` as the GitHub entrypoint and `docs/index.md` as the docs
  landing page.
- Do not add duplicate overview pages such as `docs/README.md`.
- Keep Terraform variable, output, and module descriptions complete enough for
  `terraform-docs`; generated Markdown is the canonical reference surface.
- Prefer `just` targets in docs when they exist instead of duplicating raw
  Terraform and shell commands.
- Keep secret-handling workflows, bootstrap order, and operator cautions in
  explanatory docs rather than embedding them in generated reference blocks.
