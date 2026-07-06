#!/usr/bin/env bash
# SessionStart hook: surface context/ index at session start.
set -euo pipefail

PROJECT_DIR="${VIQO_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-.}}"
cd "$PROJECT_DIR" || exit 0

if [[ ! -f context/README.md ]]; then
  exit 0
fi

echo "📚 Viqo repo context available in context/ ($(wc -l < context/README.md | tr -d ' ') line index)."
echo "   Use the viqo-developer agent for repo work; context/ is updated after commits via post-commit hook."
echo ""
head -n 28 context/README.md | tail -n +18

exit 0
