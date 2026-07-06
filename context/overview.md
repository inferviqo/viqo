# Viqo Overview

## What is Viqo?

Viqo is an **agentic coding tool** that runs in the terminal, understands codebases, and helps developers through natural language. It can:

- Execute routine coding tasks
- Explain complex code
- Handle git workflows
- Integrate with IDEs (VS Code, JetBrains extensions)
- Respond to `@viqo` mentions on GitHub

Official docs: https://github.com/inferviqo/viqo

## Relationship to Claude Code

Viqo is built on top of **Anthropic's Claude Code** (`@anthropic-ai/claude-code`). This repository:

- **Forks/upstreams** from `anthropics/claude-code` (see `upstream` git remote)
- **Rebrands** user-facing paths: `.claude` → `.viqo`, `.claude-plugin` → `.viqo-plugin`
- **Routes API calls** to Inferviqo's backend instead of Anthropic's default
- **Maintains compatibility** via symlinks so the underlying CLI still finds `.claude` paths

The `CHANGELOG.md` in this repo tracks Viqo-branded release notes (version 2.1.x series aligned with Claude Code).

## Installation (user-facing)

Recommended install methods (npm global install is deprecated):

| Platform | Method |
|----------|--------|
| macOS/Linux | `curl -fsSL https://inferviqo.com/viqo/install.sh \| bash` |
| macOS/Linux | `brew install --cask viqo` |
| Windows | `irm https://inferviqo.com/viqo/install.ps1 \| iex` |
| Windows | `winget install Inferviqo.Viqo` |
| Deprecated | `npm install -g @inferviqo/viqo` |

## Local development install (this repo)

For contributors working in this repository:

```bash
npm install
npm run install:local   # npm install + chmod + link-compat + npm link -g
npm run configure       # merge API URL into ~/.claude/settings.json
cp viqo.config.local.json.example viqo.config.local.json  # add API key
viqo --version
```

## Core concepts

### Sessions and tools

Viqo sessions use an agent loop with tools (Read, Write, Bash, WebSearch, MCP, subagents, etc.). Permission modes, sandboxing, and hooks are configurable via settings hierarchy.

### Plugins

Extensions add slash commands, agents, skills, hooks, and MCP servers. This repo bundles 13 official plugins under `plugins/` and registers them in `.viqo-plugin/marketplace.json`.

### Settings hierarchy

Settings can live at user, project, and enterprise levels:

- Project: `.viqo/settings.json`, `.viqo/settings.local.json`
- User: `~/.viqo/` or `~/.claude/` (compatibility)
- Enterprise: managed-settings via MDM (see `examples/mdm/`)

### Data and privacy

Usage data (accept/reject, conversation, `/bug` feedback) is collected per Inferviqo policy. See README and LICENSE.md.

## Branding conventions in this repo

| Claude Code | Viqo |
|-------------|------|
| `.claude/` | `.viqo/` |
| `.claude-plugin/` | `.viqo-plugin/` |
| `CLAUDE_*` env vars | `VIQO_*` (+ `ANTHROPIC_*` for runtime compat) |
| `@claude` on GitHub | `@viqo` |
| `claude` CLI | `viqo` CLI (wrapper) |

## Key entry points

| Path | Role |
|------|------|
| `bin/viqo` | Bash wrapper → `claude` binary with config |
| `viqo.config.json` | Default `apiBaseUrl` |
| `viqo.config.local.json` | Local API key (gitignored) |
| `scripts/load-config.sh` | Exports env vars before exec |
| `.viqo-plugin/marketplace.json` | Bundled plugin marketplace manifest |
| `plugins/` | Official plugin sources |
