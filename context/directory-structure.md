# Directory Structure

```
viqo/
├── bin/viqo                    # CLI entry wrapper
├── viqo.config.json            # Committed API base URL
├── viqo.config.local.json.example
├── package.json                # @inferviqo/viqo, depends on claude-code
├── CHANGELOG.md                # Release notes (Viqo-branded, 2.1.x)
├── README.md                   # User-facing docs
├── LICENSE.md                  # © Inferviqo
├── SECURITY.md                 # security@inferviqo.com
├── demo.gif
├── feed.xml
│
├── .viqo/                      # Project-level Viqo config
│   ├── settings.json           # Env defaults for this repo
│   └── commands/               # Repo-specific slash commands
│       ├── triage-issue.md
│       ├── dedupe.md
│       └── commit-push-pr.md
│
├── .viqo-plugin/
│   └── marketplace.json        # Bundled plugin marketplace manifest
│
├── .claude/                    # Symlink → .viqo (compat)
├── .claude-plugin/             # Symlink → .viqo-plugin (compat)
│
├── plugins/                    # 13 official plugins (see plugins.md)
│   ├── README.md
│   ├── agent-sdk-dev/
│   ├── code-review/
│   ├── commit-commands/
│   ├── explanatory-output-style/
│   ├── feature-dev/
│   ├── frontend-design/
│   ├── hookify/
│   ├── learning-output-style/
│   ├── model-migration/
│   ├── plugin-dev/
│   ├── pr-review-toolkit/
│   ├── ralph-wiggum/
│   └── security-guidance/
│
├── scripts/                    # Repo maintenance & GitHub helpers
│   ├── load-config.sh          # API env loading (used by bin/viqo)
│   ├── install-local.sh        # npm run install:local
│   ├── link-compat.sh          # .viqo ↔ .claude symlinks
│   ├── configure-user-settings.sh
│   ├── gh.sh                   # Restricted gh CLI wrapper
│   ├── edit-issue-labels.sh
│   ├── comment-on-duplicates.sh
│   ├── sweep.ts                # Issue lifecycle enforcement (Bun)
│   ├── issue-lifecycle.ts      # Label timeouts (shared constants)
│   ├── lifecycle-comment.ts
│   ├── auto-close-duplicates.ts
│   └── backfill-duplicate-comments.ts
│
├── .github/
│   ├── workflows/              # 12 automation workflows
│   └── ISSUE_TEMPLATE/         # bug, feature, docs, model_behavior
│
├── examples/
│   ├── settings/               # lax, strict, bash-sandbox JSON
│   ├── mdm/                    # macOS/Windows enterprise deploy
│   ├── gateway/gcp/            # Gateway on GCP reference
│   └── hooks/                  # bash_command_validator example
│
├── .devcontainer/              # Viqo Sandbox dev environment
├── Script/                     # run_devcontainer_viqo.ps1
├── context/                    # This documentation set
└── node_modules/
    └── @anthropic-ai/claude-code/   # Actual CLI runtime
```

## Path conventions

### Viqo-branded paths (preferred)

| Path | Purpose |
|------|---------|
| `.viqo/settings.json` | Project settings |
| `.viqo/commands/*.md` | Custom slash commands |
| `.viqo-plugin/plugin.json` | Plugin metadata |
| `.viqo-plugin/marketplace.json` | Marketplace manifest |
| `.viqo/rules/` | Conditional rules (upstream feature) |
| `.viqo/hookify.*.md` | Hookify plugin rules |

### Compatibility symlinks

After `link-compat.sh`, equivalent `.claude*` paths exist for the underlying runtime.

## Git remotes

| Remote | URL | Purpose |
|--------|-----|---------|
| `origin` | `github.com/inferviqo/viqo` | Inferviqo fork/distribution |
| `upstream` | `github.com/anthropics/claude-code` | Anthropic source |

## Ignored files (`.gitignore`)

- `node_modules/`
- `viqo.config.local.json` (API keys)
- `.DS_Store`
