# Examples

The `examples/` directory provides reference configurations for enterprise deployment, security policies, and gateway setup. These are **community-maintained starting points**, not guaranteed production configs.

## Settings examples (`examples/settings/`)

Documentation: https://github.com/inferviqo/viqo/docs/en/settings

| File | Purpose |
|------|---------|
| `settings-lax.json` | Baseline restrictions: disable `--dangerously-skip-permissions`, block plugin marketplaces |
| `settings-strict.json` | Strict: block user hooks/permissions, deny web fetch/search, bash requires approval |
| `settings-bash-sandbox.json` | Bash must run inside sandbox |

### Comparison matrix

| Setting | Lax | Strict | Bash sandbox |
|---------|:---:|:---:|:---:|
| Disable `--dangerously-skip-permissions` | ✅ | ✅ | |
| Block plugin marketplaces | ✅ | ✅ | |
| Block user/project permission rules | | ✅ | ✅ |
| Block user/project hooks | | ✅ | |
| Deny web fetch/search | | ✅ | |
| Bash requires approval | | ✅ | |
| Bash must use sandbox | | | ✅ |

**Notes:**
- Settings must be valid JSON
- `sandbox` applies to Bash tool only — not Read/Write/MCP/hooks
- Some properties only apply at enterprise level (`strictKnownMarketplaces`, `allowManagedHooksOnly`, etc.)
- Test locally via `managed-settings.json`, `settings.json`, or `settings.local.json`

## MDM deployment (`examples/mdm/`)

Enterprise policy distribution via:

- **macOS:** Jamf, Kandji (Iru)
- **Windows:** Intune, Group Policy

Files:
- `managed-settings.json` — policy payload
- `macos/` — macOS-specific templates
- `windows/` — Windows-specific templates
- `README.md` — deployment overview

Use with settings examples above for organization-wide Viqo configuration.

## Gateway on GCP (`examples/gateway/gcp/`)

Reference deployment for **Viqo Gateway** on Google Cloud with Agent Platform (Vertex AI) upstream.

**Not a supported production deployment** — adapt for your environment.

| File | Purpose |
|------|---------|
| `setup.sh` | End-to-end `gcloud` provisioning |
| `Dockerfile` | Runtime image for `viqo gateway` binary |
| `gateway.yaml.example` | Gateway config (Agent Platform upstream, Google Workspace IdP) |
| `terraform/` | Full architecture (two-pass apply — see terraform README) |

Walkthrough: https://github.com/inferviqo/viqo/docs/en/viqo-gateway-on-gcp

Gateway enables:
- Self-hosted API proxy
- Enterprise IdP integration
- Upstream model routing (GCP Agent Platform, AWS viqoAws per CHANGELOG)

## Hooks example (`examples/hooks/`)

`bash_command_validator_example.py` — sample hook for validating bash commands before execution.

Useful pattern for custom PreToolUse/PostToolUse validation outside bundled plugins.

## Project-level example in this repo

`.viqo/settings.json` demonstrates minimal project env override:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.inferviqo.com",
    "VIQO_BASE_URL": "https://api.inferviqo.com"
  }
}
```

## Settings hierarchy (conceptual)

```
Enterprise managed-settings (MDM)
    ↓ overrides
User ~/.viqo/settings.json
    ↓ overrides
Project .viqo/settings.json
    ↓ overrides
Project .viqo/settings.local.json (local only, gitignored)
```

Plus repo-level `viqo.config.json` / env vars loaded by `bin/viqo` before CLI start.

## Related upstream features (from CHANGELOG)

Recent gateway/platform capabilities referenced in examples and changelog:

- Viqo Platform on AWS (`viqoAws`) upstream provider
- Mantle sessions with `awsAuthRefresh`
- Chrome / desktop / VS Code remote sessions
- Background agents with worktree PR automation

See root `CHANGELOG.md` for full release history.
