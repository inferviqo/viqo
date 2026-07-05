#!/usr/bin/env bash
# Claude Code runtime expects .claude-plugin paths and CLAUDE_PLUGIN_ROOT.
# This script adds compatibility symlinks alongside the Viqo-branded paths.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

link_if_missing() {
  local target="$1"
  local link="$2"
  if [[ -e "$link" && ! -L "$link" ]]; then
    echo "skip $link (exists and is not a symlink)" >&2
    return
  fi
  ln -sfn "$target" "$link"
  echo "linked $link -> $target"
}

link_if_missing ".viqo-plugin" ".claude-plugin"
link_if_missing ".viqo" ".claude"

while IFS= read -r plugin_json; do
  plugin_dir="$(dirname "$(dirname "$plugin_json")")"
  link_if_missing ".viqo-plugin" "$plugin_dir/.claude-plugin"
done < <(find plugins -path '*/.viqo-plugin/plugin.json' -print)

echo "Compatibility symlinks ready."
