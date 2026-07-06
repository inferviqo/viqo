# Development Guide

## Prerequisites

- **Node.js 18+**
- **npm** (for install scripts)
- **Python 3** (config parsing in `load-config.sh`)
- **Bun** (for TypeScript maintenance scripts in CI/local)
- **gh CLI** (for GitHub automation testing)

## Quick start

```bash
git clone https://github.com/inferviqo/viqo.git
cd viqo

npm install
npm run install:local
npm run configure

cp viqo.config.local.json.example viqo.config.local.json
# Edit viqo.config.local.json with your API key

viqo --version
viqo plugin marketplace add "$(pwd)"
viqo plugin install commit-commands@viqo-plugins
```

## npm scripts

| Script | Command | Description |
|--------|---------|-------------|
| `install:local` | `bash scripts/install-local.sh` | Full local setup: npm install, chmod, link-compat, npm link -g |
| `link:compat` | `bash scripts/link-compat.sh` | Create .claude ↔ .viqo symlinks |
| `configure` | `bash scripts/configure-user-settings.sh` | Merge API URL into ~/.claude/settings.json |

## Local install steps (detail)

`scripts/install-local.sh`:

1. `npm install` — pulls `@anthropic-ai/claude-code`
2. `chmod +x bin/viqo`
3. `link-compat.sh` — symlink branded paths
4. `npm link` — global `viqo` command

Post-install reminders printed:
- Run `npm run configure`
- Create `viqo.config.local.json`
- Register marketplace: `viqo plugin marketplace add "$ROOT"`
- Install plugins: `viqo plugin install commit-commands@viqo-plugins`

## Configuration for local dev

### API endpoint

Default in `viqo.config.json`:
```
https://api.inferviqo.com
```

Override via env before running:
```bash
export VIQO_BASE_URL="https://api.inferviqo.com"
export VIQO_API_KEY="your-key"
viqo
```

### User settings

`configure-user-settings.sh` targets `~/.claude/settings.json` (Claude Code compat path) and sets:
- `env.ANTHROPIC_BASE_URL`
- `env.VIQO_BASE_URL`

## Devcontainer

**Name:** Viqo Sandbox  
**Config:** `.devcontainer/devcontainer.json`

Features:
- Custom Dockerfile with Viqo, git-delta, zsh-in-docker
- VS Code extensions: `inferviqo.viqo`, ESLint, Prettier, GitLens
- Capabilities: `NET_ADMIN`, `NET_RAW` (firewall init)
- Volumes: bash history, `~/.viqo` config
- `VIQO_CONFIG_DIR=/home/node/.viqo`
- Post-start: `init-firewall.sh`

Windows helper: `Script/run_devcontainer_viqo.ps1`

## Testing plugins locally

```bash
# Single plugin directory
viqo --plugin-dir "$(pwd)/plugins/hookify"

# Marketplace flow
viqo plugin marketplace add "$(pwd)"
viqo plugin install hookify@viqo-plugins
```

After adding plugins under `plugins/`, re-run:
```bash
npm run link:compat
```

## Running maintenance scripts

### Issue sweep (dry run)

```bash
export GITHUB_TOKEN="..."
export GITHUB_REPOSITORY="inferviqo/viqo"
bun run scripts/sweep.ts --dry-run
```

### gh wrapper locally

```bash
export GITHUB_REPOSITORY="inferviqo/viqo"
./scripts/gh.sh issue list --state open --limit 5
```

## Syncing with upstream

```bash
git fetch upstream
git merge upstream/main   # or rebase, per team policy
npm install               # refresh claude-code version
npm run link:compat
```

Upstream: `anthropics/claude-code` — most CHANGELOG entries originate there, rebranded for Viqo.

## Version alignment

- `package.json` version: `0.1.0` (wrapper package)
- `@anthropic-ai/claude-code`: `^2.1.201`
- `CHANGELOG.md`: tracks 2.1.x runtime releases

Check installed runtime:
```bash
viqo --version
ls node_modules/@anthropic-ai/claude-code/package.json
```

## VS Code

Recommended extensions in `.vscode/extensions.json`. Project uses Prettier + ESLint on save in devcontainer.

## Security notes for contributors

- Never commit `viqo.config.local.json` (gitignored)
- Use restricted `gh.sh` in automation commands, not raw `gh`
- GitHub workflows rely on OIDC federation, not long-lived API keys in YAML
