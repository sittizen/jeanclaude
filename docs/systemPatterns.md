# System Patterns: JeanClaude

## Architecture Overview

```mermaid
flowchart TB
    subgraph Host["Host Machine"]
        Project["Python Project<br>/path/to/project"]
        RunScript["run.sh"]
    end

    subgraph Container["Docker Container"]
        ZshRC["zshrc<br>(entry point)"]
        Vault["Vault Client"]
        CheckDevTools["check_dev_tools.sh"]
        CheckPoeTasks["check_poe_tasks.py"]
        
        subgraph SourceOfTruth["Source of Truth"]
            DevToolsMd["dev_tools.md"]
            PoeTasksToml["poe_tasks.toml"]
        end
        
        MountedProject["/app<br>(mounted project)"]
    end

    RunScript -->|"docker run -v"| Container
    Project -->|"bind mount"| MountedProject
    
    ZshRC --> Vault
    ZshRC --> CheckDevTools
    ZshRC --> CheckPoeTasks
    
    Vault -->|"inject credentials"| MountedProject
    CheckDevTools -->|"sync versions"| MountedProject
    CheckPoeTasks -->|"sync tasks"| MountedProject
    
    DevToolsMd --> CheckDevTools
    PoeTasksToml --> CheckPoeTasks
```

## Key Technical Decisions

### 1. File Overlay Pattern
- **Decision**: Use `files/` directory structure mirroring Linux FHS
- **Rationale**: 
  - `files/etc/` - System configuration (zshrc)
  - `files/opt/` - Application scripts (prechecks)
  - `files/usr/` - Additional data (CA certificates)
- **Implementation**: `COPY files/ /` copies overlay directly to root filesystem

### 2. Startup-Time Synchronization
- **Decision**: Run sync scripts at shell initialization (via zshrc)
- **Rationale**: Ensures every interactive session starts with correct tooling
- **Trade-off**: Slight startup delay vs guaranteed consistency

### 3. Credential Injection via Vault
- **Decision**: Fetch credentials from HashiCorp Vault at startup
- **Implementation**: 
  ```bash
  vault read -format json kv/prd/gitlab | jq -r '...'
  ```
- **Exposed Variables**:
  - `UV_INDEX_PYPIMOL_GITLAB_USERNAME` - PyPI registry user
  - `UV_INDEX_PYPIMOL_GITLAB_PASSWORD` - PyPI registry password

### 4. Source-of-Truth Files

| File | Purpose | Format |
|------|---------|--------|
| `dev_tools.md` | Dev dependency versions | `package==version` (one per line) |
| `poe_tasks.toml` | Standard poe tasks | TOML `[tool.poe.tasks]` |
