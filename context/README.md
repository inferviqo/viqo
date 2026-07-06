# Viqo Repository Context

This directory contains detailed context about the **Viqo** repository (`inferviqo/viqo`), intended for AI agents, contributors, and onboarding. It reflects the repository state as of **July 2026**.

## Quick facts

| Property | Value |
|----------|-------|
| **Product** | Viqo — agentic coding CLI (terminal, IDE, GitHub @viqo) |
| **Publisher** | Inferviqo |
| **npm package** | `@inferviqo/viqo` (v0.1.0, local dev wrapper) |
| **Underlying runtime** | `@anthropic-ai/claude-code` (^2.1.201) |
| **Default API** | `https://api.inferviqo.com` |
| **Origin remote** | `https://github.com/inferviqo/viqo.git` |
| **Upstream remote** | `https://github.com/anthropics/claude-code.git` |
| **License** | © Inferviqo. All rights reserved. |

## Documents

| File | Contents |
|------|----------|
| [overview.md](./overview.md) | Product purpose, relationship to Claude Code, branding model |
| [architecture.md](./architecture.md) | CLI wrapper, config loading, compatibility symlinks, API routing |
| [directory-structure.md](./directory-structure.md) | Top-level layout and key paths |
| [plugins.md](./plugins.md) | Bundled plugin marketplace and per-plugin capabilities |
| [github-automation.md](./github-automation.md) | CI workflows, issue triage, lifecycle, maintenance scripts |
| [development.md](./development.md) | Local install, npm scripts, devcontainer, user settings |
| [examples.md](./examples.md) | Settings, MDM, gateway, and hooks examples |

## How to use this context

- **Agents**: Read `overview.md` and `architecture.md` first, then the topic-specific doc for your task.
- **Contributors**: Start with `development.md` for local setup; use `plugins.md` when working on plugins.
- **Maintainers**: See `github-automation.md` for issue/PR automation and `scripts/`.

## viqo-developer agent

This repo includes a project agent at `.viqo/agents/viqo-developer.md` that:

1. **Reads `context/` first** before implementing or answering questions about this repo.
2. **Keeps `context/` in sync** when code, plugins, workflows, or config change.

**Automation:** `.viqo/settings.json` registers hooks that:

- **SessionStart** — prints the context index summary via `.viqo/hooks/session-load-context.sh`
- **PostToolUse (git commit)** — after `git commit`, runs `.viqo/hooks/post-commit-update-context.sh` and prompts a context update via the viqo-developer workflow

Invoke explicitly when working on the repo: *"Use the viqo-developer agent to …"*

## Repository type

This repo is **not** the full Viqo CLI source. It is a **distribution and extension layer**:

1. Wraps the published `@anthropic-ai/claude-code` binary via `bin/viqo`.
2. Re-brands paths and config (`.viqo`, `.viqo-plugin`) with Claude Code compatibility symlinks.
3. Points API traffic to Inferviqo's gateway (`api.inferviqo.com`).
4. Ships official plugins, GitHub Actions automation, and configuration examples.

Most runtime behavior lives in the `claude-code` dependency and upstream changelog (`CHANGELOG.md`).
