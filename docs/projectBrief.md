# Project Brief: JeanClaude

## Overview

JeanClaude is a **developer shell container** that provides a standardized, reproducible development environment for Python projects using the `uv` package manager.

## Problem Statement

Development teams face challenges with:
- **Environment inconsistency**: "Works on my machine" syndrome
- **Tool version drift**: Different developers using different versions of linters, test runners, and formatters
- **Onboarding friction**: New developers spending time configuring local environments
- **Credential management**: Securely distributing access to private PyPI repositories and Docker registries

## Goals

### Primary Goals
1. **Standardize development environments** - Every developer works in the same containerized environment
2. **Enforce toolchain consistency** - Automatically sync dev tool versions (mypy, pytest, ruff) across all projects
3. **Automate credential injection** - Securely fetch and inject credentials from HashiCorp Vault at container startup
4. **Standardize task definitions** - Ensure all projects have consistent poe (poethepoet) task definitions for common workflows

### User Experience Goals
- **Zero-configuration startup**: Developers mount their project and immediately have a working environment
- **Automatic synchronization**: Tool versions and task definitions are enforced without manual intervention
- **Clear feedback**: Visual confirmation of environment setup status with the `♪ᕕ(ᐛ)ᕗ` prompt indicator

## Target Users

- Python developers working on projects managed with `uv`
- Teams requiring consistent development environments
- Organizations using HashiCorp Vault for secrets management
- Projects following the `src/` layout convention

## Core Requirements

### Functional Requirements
1. Mount any `uv`-based Python project and provide interactive shell access
2. Validate that mounted projects have proper `[tool.uv]` configuration
3. Sync development tool versions from a central source-of-truth (`dev_tools.md`)
4. Sync poe task definitions from a central source-of-truth (`poe_tasks.toml`)
5. Fetch credentials from Vault and export them as environment variables

### Non-Functional Requirements
- Container must be lightweight (Alpine-based)
- Startup time should be minimal
- Must work with existing project structures without modification

## Success Metrics

- Time-to-first-command for new developers reduced
- Zero version conflicts between developer environments
- Consistent CI/CD and local development tool versions
