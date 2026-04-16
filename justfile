set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
  @just --list

enter-nix *args:
  @if [[ -n "${IN_NIX_SHELL:-}" ]]; then \
    just --justfile "{{justfile()}}" {{args}}; \
  else \
    nix develop --command just --justfile "{{justfile()}}" {{args}}; \
  fi

format:
  @just enter-nix _format

_format:
  alejandra .
  terraform fmt -recursive

lint:
  @just enter-nix _lint

_lint:
  markdownlint-cli2 $(git ls-files "*.md")
  terraform init -backend=false
  terraform validate

plan:
  @just enter-nix _plan

_plan:
  terraform init
  terraform plan

apply:
  @just enter-nix _apply

_apply:
  terraform init
  terraform apply

test:
  @just enter-nix _test

_test:
  terraform validate

build:
  @just enter-nix _build

_build:
  terraform validate

docs:
  @just enter-nix _docs

_docs:
  zensical build --clean

pre-commit:
  @just enter-nix _pre-commit

_pre-commit:
  pre-commit run --all-files --show-diff-on-failure
