# Plugins

## Marketplace

**Name:** `viqo-plugins`  
**Manifest:** `.viqo-plugin/marketplace.json`  
**Owner:** Inferviqo (support@inferviqo.com)

### Install from this repo

```bash
viqo plugin marketplace add "/path/to/viqo/repo"
viqo plugin install commit-commands@viqo-plugins
# Or load directly:
viqo --plugin-dir "/path/to/viqo/plugins/commit-commands"
```

## Standard plugin layout

```
plugin-name/
├── .viqo-plugin/
│   └── plugin.json          # name, description, version, author
├── .claude-plugin/          # symlink (after link-compat.sh)
├── commands/                # Slash command markdown files
├── agents/                  # Subagent definitions
├── skills/                  # Agent Skills (SKILL.md trees)
├── hooks/                   # Event hook scripts + hooks.json
├── hooks-handlers/          # Hook handler implementations (some plugins)
├── .mcp.json                # MCP server config (optional)
└── README.md
```

## Bundled plugins

### agent-sdk-dev
**Category:** development  
**Command:** `/new-sdk-app` — interactive Agent SDK project setup  
**Agents:** `agent-sdk-verifier-py`, `agent-sdk-verifier-ts` — validate SDK apps

### model-migration
**Category:** development  
**Skill:** `model-migration` — migrate model strings, beta headers, prompts from Sonnet 4.x / Opus 4.1 → Opus 4.5

### code-review
**Category:** productivity  
**Command:** `/code-review` — automated PR review  
**Agents:** 5 parallel Sonnet agents (VIQO.md compliance, bugs, historical context, PR history, comments) with confidence-based scoring

### commit-commands
**Category:** productivity  
**Commands:**
- `/commit` — staged commit with message
- `/commit-push-pr` — commit, push, open PR
- `/clean_gone` — clean up deleted remote branches

### explanatory-output-style
**Category:** learning  
**Hook:** `SessionStart` — injects educational context (mimics deprecated Explanatory output style)

### feature-dev
**Category:** development  
**Command:** `/feature-dev` — 7-phase feature workflow  
**Agents:** `code-explorer`, `code-architect`, `code-reviewer`

### frontend-design
**Category:** development (v1.1.0)  
**Skill:** `frontend-design` — auto-invoked for frontend work; bold typography, animation, non-generic aesthetics

### hookify
**Category:** productivity (v0.1.0)  
**Commands:** `/hookify`, `/hookify:list`, `/hookify:configure`, `/hookify:help`  
**Agent:** `conversation-analyzer`  
**Skill:** `writing-rules`  
**Mechanism:** Markdown rule files in `.viqo/hookify.*.md` with YAML frontmatter + regex matchers

### learning-output-style
**Category:** learning  
**Hook:** `SessionStart` — interactive learning mode; user writes 5–10 lines at decision points

### plugin-dev
**Category:** development (v0.1.0)  
**Command:** `/plugin-dev:create-plugin` — 8-phase plugin creation workflow  
**Agents:** `agent-creator`, `plugin-validator`, `skill-reviewer`  
**Skills (7):** hook-development, mcp-integration, plugin-structure, plugin-settings, command-development, agent-development, skill-development

Note: `plugin-dev` has no `.viqo-plugin/plugin.json` in tree — loaded via marketplace `source` path.

### pr-review-toolkit
**Category:** productivity  
**Command:** `/pr-review-toolkit:review-pr` — optional aspects: comments, tests, errors, types, code, simplify, all  
**Agents:** `comment-analyzer`, `pr-test-analyzer`, `silent-failure-hunter`, `type-design-analyzer`, `code-reviewer`, `code-simplifier`

### ralph-wiggum
**Category:** development  
**Commands:** `/ralph-loop`, `/cancel-ralph`  
**Hook:** `Stop` — blocks session exit to continue iterative self-referential loops  
**Scripts:** `scripts/setup-ralph-loop.sh`

### security-guidance
**Category:** security  
**Hook:** `PreToolUse` — warns on 9 security patterns (command injection, XSS, eval, dangerous HTML, pickle, os.system, etc.)

## Plugin command frontmatter

Repo-level commands in `.viqo/commands/` use YAML frontmatter:

```yaml
---
allowed-tools: Bash(./scripts/gh.sh:*),Bash(./scripts/edit-issue-labels.sh:*)
description: Triage GitHub issues by analyzing and applying labels
---
```

`allowed-tools` restricts which tools the command may use (important for GitHub automation).

## Categories in marketplace

| Category | Plugins |
|----------|---------|
| development | agent-sdk-dev, model-migration, feature-dev, frontend-design, plugin-dev, ralph-wiggum |
| productivity | code-review, commit-commands, hookify, pr-review-toolkit |
| learning | explanatory-output-style, learning-output-style |
| security | security-guidance |

## Contributing a new plugin

Per `plugins/README.md`:

1. Follow standard plugin structure
2. Add `README.md` with usage examples
3. Add `.viqo-plugin/plugin.json`
4. Register in `.viqo-plugin/marketplace.json`
5. Run `scripts/link-compat.sh` for `.claude-plugin` symlinks
