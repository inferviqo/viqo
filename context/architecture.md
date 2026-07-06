# Architecture

## High-level flow

```
User runs `viqo`
    │
    ▼
bin/viqo (bash)
    │
    ├─► scripts/load-config.sh
    │       Reads viqo.config.json → VIQO_BASE_URL / ANTHROPIC_BASE_URL
    │       Reads viqo.config.local.json → VIQO_API_KEY / ANTHROPIC_API_KEY
    │       Unsets Bedrock/Vertex/Foundry/Mantle when custom URL set
    │
    ├─► Sets VIQO_REPO_ROOT
    │
    └─► exec node_modules/.bin/claude "$@"
            (fallback: claude on PATH)
```

## CLI wrapper (`bin/viqo`)

The wrapper is intentionally thin (~34 lines):

1. Resolves repo root from script location
2. Sources `load_viqo_config`
3. Finds `claude` binary (`node_modules/.bin/claude` or PATH)
4. Exports `VIQO_REPO_ROOT`
5. `exec` into Claude Code with passthrough args

No TypeScript/JavaScript application code ships in this repo for the CLI itself — all runtime logic is in `@anthropic-ai/claude-code`.

## Configuration system

### `viqo.config.json` (committed)

```json
{
  "apiBaseUrl": "https://api.inferviqo.com"
}
```

### `viqo.config.local.json` (gitignored)

```json
{
  "apiKey": "your-api-key-here"
}
```

### Environment variable mapping

| Config field | Primary export | Runtime compat |
|--------------|----------------|----------------|
| `apiBaseUrl` | `VIQO_BASE_URL` | `ANTHROPIC_BASE_URL` |
| `apiKey` | `VIQO_API_KEY` | `ANTHROPIC_API_KEY` |

User can override via shell env before invoking `viqo`.

When `ANTHROPIC_BASE_URL` is set, third-party provider flags are cleared:
- `CLAUDE_CODE_USE_BEDROCK`
- `CLAUDE_CODE_USE_VERTEX`
- `CLAUDE_CODE_USE_FOUNDRY`
- `CLAUDE_CODE_USE_MANTLE`

### Project settings (`.viqo/settings.json`)

This repo's project settings set default env for sessions in this workspace:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.inferviqo.com",
    "VIQO_BASE_URL": "https://api.inferviqo.com"
  }
}
```

### User settings merge (`npm run configure`)

`scripts/configure-user-settings.sh` writes to `~/.claude/settings.json`:

- Merges `apiBaseUrl` from repo config
- Sets `env.ANTHROPIC_BASE_URL` and `env.VIQO_BASE_URL`

## Compatibility layer (`scripts/link-compat.sh`)

Claude Code runtime expects `.claude-plugin` and `.claude` paths. Viqo uses branded paths with symlinks:

```
.viqo-plugin  ←→  .claude-plugin   (repo root)
.viqo         ←→  .claude           (repo root)
plugins/*/.viqo-plugin  ←→  plugins/*/.claude-plugin
```

Run automatically during `npm run install:local`. Safe to re-run; uses `ln -sfn`.

## Plugin marketplace

`.viqo-plugin/marketplace.json` defines the `viqo-plugins` marketplace:

- Schema: `https://json.schemastore.org/viqo-code-marketplace.json`
- 13 plugins with relative `source` paths under `./plugins/`
- Register locally: `viqo plugin marketplace add "$REPO_ROOT"`

## GitHub integration architecture

Production GitHub automation uses **`inferviqo/viqo-action@v1`** with **Workload Identity Federation** (OIDC → short-lived Viqo API token), not static API keys.

Required GitHub repo variables:
- `VIQO_FEDERATION_RULE_ID`
- `VIQO_ORGANIZATION_ID`
- `VIQO_SERVICE_ACCOUNT_ID`
- `VIQO_WORKSPACE_ID`

Workflows trigger on `@viqo` mentions or run scheduled/maintenance tasks.

## Dependencies

```json
{
  "dependencies": {
    "@anthropic-ai/claude-code": "^2.1.201"
  }
}
```

The npm package `@inferviqo/viqo` is marked `"private": true` — this repo is for local/dev distribution, not npm publishing of the wrapper itself (production installs use install.sh / Homebrew / WinGet).

## What is NOT in this repo

- Viqo CLI core TypeScript source (upstream Claude Code binary)
- Viqo API server implementation
- VS Code extension source (referenced as `inferviqo.viqo` in devcontainer)
- `viqo-action` GitHub Action source (external: `inferviqo/viqo-action`)
