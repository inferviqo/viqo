#!/usr/bin/env bash
# shellcheck disable=SC2034
# Loaded by bin/viqo — sets API env vars from viqo.config*.json

load_viqo_config() {
  local repo_root="$1"
  local config="$repo_root/viqo.config.json"
  local local_config="$repo_root/viqo.config.local.json"

  _read_json_field() {
    local file="$1"
    local field="$2"
    python3 - "$file" "$field" <<'PY'
import json, sys
path, field = sys.argv[1], sys.argv[2]
try:
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    value = data.get(field)
    if value is not None and value != "":
        print(value)
except (OSError, json.JSONDecodeError):
    pass
PY
  }

  if [[ -f "$config" ]]; then
    local url
    url="$(_read_json_field "$config" apiBaseUrl)"
    if [[ -n "$url" ]]; then
      export VIQO_BASE_URL="${VIQO_BASE_URL:-$url}"
      export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-$url}"
    fi
  fi

  if [[ -f "$local_config" ]]; then
    local key
    key="$(_read_json_field "$local_config" apiKey)"
    if [[ -n "$key" ]]; then
      export VIQO_API_KEY="${VIQO_API_KEY:-$key}"
      export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$key}"
    fi
  fi

  # Allow VIQO_* overrides to flow into the underlying CLI runtime.
  export ANTHROPIC_BASE_URL="${ANTHROPIC_BASE_URL:-${VIQO_BASE_URL:-}}"
  export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-${VIQO_API_KEY:-}}"

  # Custom API URL: skip third-party provider onboarding (Bedrock / Vertex / etc.).
  if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
    unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY CLAUDE_CODE_USE_MANTLE
  fi
}
