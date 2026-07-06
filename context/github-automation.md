# GitHub Automation

This repository uses Viqo itself (via GitHub Actions) for issue triage, deduplication, and lifecycle management.

## Authentication model

Workflows use **`inferviqo/viqo-action@v1`** with **Workload Identity Federation**:

- GitHub OIDC token → short-lived Viqo API access token
- No static `VIQO_API_KEY` in workflow secrets for API auth
- Repo variables required: `VIQO_FEDERATION_RULE_ID`, `VIQO_ORGANIZATION_ID`, `VIQO_SERVICE_ACCOUNT_ID`, `VIQO_WORKSPACE_ID`

GitHub API access uses `secrets.GITHUB_TOKEN` or explicit `github_token` input.

## Workflows (`.github/workflows/`)

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `viqo.yml` | `@viqo` in issues, PR comments, reviews | General @viqo responses |
| `viqo-issue-triage.yml` | Issue opened, issue comment | Runs `/triage-issue` command |
| `viqo-dedupe-issues.yml` | (dedupe automation) | Duplicate issue detection |
| `sweep.yml` | Cron 10:00 & 22:00 UTC, manual | Enforce lifecycle label timeouts |
| `issue-lifecycle-comment.yml` | Lifecycle events | Post nudge comments |
| `auto-close-duplicates.yml` | Duplicate handling | Auto-close marked duplicates |
| `backfill-duplicate-comments.yml` | Maintenance | Backfill duplicate comments |
| `lock-closed-issues.yml` | Scheduled | Lock old closed issues |
| `remove-autoclose-label.yml` | Event-driven | Remove autoclose label |
| `non-write-users-check.yml` | PR/issue events | Validate non-write user restrictions |
| `log-issue-events.yml` | Issue events | Audit logging |
| `issue-opened-dispatch.yml` | Issue opened | Dispatch routing |

### Issue triage (`viqo-issue-triage.yml`)

- **Model:** `viqo-opus-4-6`
- **Prompt:** `/triage-issue REPO: ... ISSUE_NUMBER: ... EVENT: ...`
- **Concurrency:** per-issue group, cancel-in-progress
- **Script cap:** `VIQO_CODE_SCRIPT_CAPS: '{"edit-issue-labels.sh":2}'`
- Skips bot comments and PR-linked issue comments

### @viqo workflow (`viqo.yml`)

- **Model:** `viqo-sonnet-4-5-20250929`
- Triggers when `@viqo` appears in issue body/title, comments, or PR reviews

## Repo slash commands (`.viqo/commands/`)

### `/triage-issue`

Analyzes issues and applies labels only (no comments).

**Tools allowed:**
- `./scripts/gh.sh` — restricted gh wrapper
- `./scripts/edit-issue-labels.sh` — add/remove labels

**Logic highlights:**
- Validates issue is about Viqo (CLI signals: `viqo --version`, `.viqo/`, MCP, etc.)
- Applies category labels: bug, enhancement, question, invalid, duplicate
- Lifecycle labels: `needs-repro`, `needs-info` (bugs only, 7-day timeout)
- On comments: removes stale/autoclose; clears needs-* when info provided
- Never invents labels — must come from `gh label list`

### `/dedupe`

Finds up to 3 duplicate issues using parallel search agents.

**Tools:**
- `./scripts/gh.sh`
- `./scripts/comment-on-duplicates.sh --potential-duplicates <ids>`

### `/commit-push-pr`

Git workflow command (also available via commit-commands plugin).

## Restricted GitHub CLI (`scripts/gh.sh`)

Security wrapper around `gh` — only allows:

| Command | Example |
|---------|---------|
| `issue view` | `./scripts/gh.sh issue view 123 --comments` |
| `issue list` | `./scripts/gh.sh issue list --state open --limit 20` |
| `search issues` | `./scripts/gh.sh search issues "query" --limit 10` |
| `label list` | `./scripts/gh.sh label list --limit 100` |

Requires `GH_REPO` or `GITHUB_REPOSITORY` in `owner/repo` format. Validates allowed flags only.

## Issue lifecycle (`scripts/issue-lifecycle.ts`)

Single source of truth for label timeouts:

| Label | Days | Close reason |
|-------|------|--------------|
| `invalid` | 3 | Not about Viqo |
| `needs-repro` | 7 | Missing reproduction steps |
| `needs-info` | 7 | Missing version/env/logs |
| `stale` | 14 | Inactivity |
| `autoclose` | 14 | Marked for auto-close |

**Stale threshold:** issues with ≥10 upvotes skip stale/autoclose (`STALE_UPVOTE_THRESHOLD = 10`).

### Sweep script (`scripts/sweep.ts`)

- Runs on **Bun** (`bun run scripts/sweep.ts`)
- Supports `--dry-run`
- Closes issues past lifecycle deadlines with templated message linking to new issue form

## Other maintenance scripts

| Script | Runtime | Purpose |
|--------|---------|---------|
| `auto-close-duplicates.ts` | Bun | Close duplicate issues |
| `backfill-duplicate-comments.ts` | Bun | Backfill dup comments |
| `lifecycle-comment.ts` | Bun | Post lifecycle nudges |
| `edit-issue-labels.sh` | Bash | Add/remove labels from workflow event |
| `comment-on-duplicates.sh` | Bash | Post duplicate suggestions |

## Issue templates

`.github/ISSUE_TEMPLATE/`:

- `bug_report.yml` — structured bug reports (version, OS, repro)
- `feature_request.yml`
- `documentation.yml`
- `model_behavior.yml`
- `config.yml` — template chooser

Bug template references `@inferviqo/viqo` npm and `viqo --version`.

## Models used in automation

| Workflow | Model |
|----------|-------|
| Issue triage | `viqo-opus-4-6` |
| @viqo general | `viqo-sonnet-4-5-20250929` |

These are Inferviqo-hosted model identifiers routed through `api.inferviqo.com`.
