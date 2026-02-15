# Project Brief: jeanclaude

## Overview

jeanclaude is a containerized developer shell environment for Python projects managed by `uv` (Astral's Python package manager). It provides a portable, reproducible development shell that enforces consistent dev tooling across projects.

## Problem Statement

Python development environments are fragile and inconsistent across machines and teams. Developers working on `uv`-managed projects need:

- A consistent shell environment regardless of host OS
- Enforced dev dependency versions (e.g., test runners, linters) that match team standards
- A quick way to spin up a validated development shell without manual setup

## Core Requirements

1. **Containerized Dev Shell** -- Provide an interactive zsh shell inside a Docker container with the host project mounted, so developers work in a controlled environment
2. **Project Validation** -- Before granting shell access, verify the target directory is a valid `uv`-managed Python project (has `pyproject.toml` with `[tool.uv]`)
3. **Dev Tool Enforcement** -- On every shell startup, validate that dev dependencies match pinned versions defined in a declarative manifest (`dev_tools.md`)
4. **Self-Healing Dependencies** -- When version mismatches are detected, automatically attempt to correct them via `uv add`
5. **Extensibility** -- Support future actions beyond `shell` (placeholders exist for `publish` and `deploy`)

## User Experience Goals

- **Single command startup**: `./run.sh --action shell --path /path/to/project` drops the developer into a validated shell
- **Fail-fast validation**: Problems with the project or dev tools surface immediately on shell startup, not during a test run or deploy
- **Minimal host requirements**: Only Docker and a vterminal needed on the host machine
- **Transparent**: The developer sees clear output about what checks passed/failed and what was auto-fixed

## Scope

### In Scope

- Docker-based shell environment for `uv`-managed Python projects
- Declarative dev tool version pinning and enforcement
- Interactive zsh shell with sensible defaults (keybindings, completion)
- CLI with action-based dispatch (`shell`, future: `publish`, `deploy`)

### Still TODO
- `publish` and `deploy` actions (placeholders only)

### Out of Scope
- Support for non-`uv` Python projects
- GUI or IDE integration
- Multi-container or docker-compose setups
