#!/usr/bin/env bash
# PostToolUse hook: after `git commit`, remind viqo-developer to update context/.
set -euo pipefail

PROJECT_DIR="${VIQO_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-.}}"
cd "$PROJECT_DIR" || exit 0

# Consume hook stdin (required by PostToolUse protocol)
cat >/dev/null || true

python3 <<'PY'
import json
import subprocess
import sys
from pathlib import Path

def git_changed_files():
    try:
        out = subprocess.check_output(
            ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD"],
            stderr=subprocess.DEVNULL,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return []
    return [line.strip() for line in out.splitlines() if line.strip()]

def context_docs_for(path: str) -> set[str]:
    docs: set[str] = set()
    if path.startswith("context/"):
        return docs
    if path in {"README.md", "LICENSE.md", "CHANGELOG.md", "package.json", "package-lock.json"}:
        docs.update({"context/overview.md", "context/development.md", "context/README.md"})
    elif path.startswith(("bin/", "viqo.config")) or path in {
        "scripts/load-config.sh",
        "scripts/link-compat.sh",
        "scripts/install-local.sh",
        "scripts/configure-user-settings.sh",
    }:
        docs.update({"context/architecture.md", "context/development.md"})
    elif path.startswith(("plugins/", ".viqo-plugin/")):
        docs.update({"context/plugins.md", "context/directory-structure.md"})
    elif path.startswith(".github/"):
        docs.add("context/github-automation.md")
    elif path.startswith("scripts/"):
        docs.update({"context/github-automation.md", "context/development.md"})
    elif path.startswith("examples/"):
        docs.add("context/examples.md")
    elif path.startswith((".devcontainer/", ".vscode/", "Script/")):
        docs.add("context/development.md")
    elif path.startswith(".viqo/"):
        docs.update({"context/development.md", "context/architecture.md", "context/README.md"})
    else:
        docs.add("context/directory-structure.md")
    return docs

changed = git_changed_files()
non_context = [f for f in changed if not f.startswith("context/")]
if not non_context:
    sys.exit(0)

all_docs: set[str] = set()
for f in non_context:
    all_docs.update(context_docs_for(f))

lines = [
    "Post-commit context sync: this commit changed repo files outside context/.",
    "",
    "Changed files:",
    *[f"- {f}" for f in non_context],
    "",
    "Review and update these context docs (use the viqo-developer agent):",
    *[f"- {d}" for d in sorted(all_docs)],
    "",
    "Workflow: read changed sources → update listed context/*.md → refresh date in context/README.md if facts changed.",
]

print(json.dumps({"systemMessage": "\n".join(lines)}))
PY

exit 0
