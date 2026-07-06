#!/usr/bin/env bash
# shellcheck disable=SC2034
# Loaded by bin/viqo — sets API env vars from viqo.config*.json

load_viqo_config() {
  local repo_root="$1"
  local config=""
  local local_config=""

  # Prefer project-local config in cwd, then the viqo install directory.
  if [[ -f "$(pwd)/viqo.config.json" ]]; then
    config="$(pwd)/viqo.config.json"
    local_config="$(pwd)/viqo.config.local.json"
  elif [[ -f "$repo_root/viqo.config.json" ]]; then
    config="$repo_root/viqo.config.json"
    local_config="$repo_root/viqo.config.local.json"
  fi

  _read_json_field() {
    local file="$1"
    local field="$2"
    if [[ ! -f "$file" ]]; then
      return 0
    fi
    if command -v node >/dev/null 2>&1; then
      node - "$file" "$field" <<'NODE'
const fs = require("fs");
const [, , file, field] = process.argv;
try {
  const data = JSON.parse(fs.readFileSync(file, "utf8"));
  const value = data[field];
  if (value !== undefined && value !== null && value !== "") {
    process.stdout.write(String(value));
  }
} catch {
  // ignore
}
NODE
      return 0
    fi
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

  local url="" model="" key=""

  if [[ -n "$config" ]]; then
    export VIQO_CONFIG_DIR="$(cd "$(dirname "$config")" && pwd)"
    url="$(_read_json_field "$config" apiBaseUrl)"
    model="$(_read_json_field "$config" model)"
  fi

  if [[ -f "$local_config" ]]; then
    key="$(_read_json_field "$local_config" apiKey)"
  fi

  # Trim trailing slash. Claude Code appends /v1/messages to ANTHROPIC_BASE_URL,
  # so the base must NOT include a /v1 suffix (otherwise requests hit /v1/v1/...).
  url="${url%/}"
  while [[ "$url" == */v1 ]]; do
    url="${url%/v1}"
  done

  if [[ -n "$url" ]]; then
    export VIQO_BASE_URL="$url"
    export ANTHROPIC_BASE_URL="$url"
  fi

  if [[ -n "$model" ]]; then
    export VIQO_MODEL="$model"
  fi

  if [[ -n "$key" ]]; then
    export VIQO_API_KEY="$key"
    export ANTHROPIC_API_KEY="$key"
  fi

  # Custom API URL: skip third-party provider onboarding (Bedrock / Vertex / etc.).
  if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
    unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY CLAUDE_CODE_USE_MANTLE
  fi
}

# JSON blob for `claude --settings` so runtime env matches viqo.config*.json.
build_viqo_settings_override() {
  if [[ -z "${ANTHROPIC_BASE_URL:-}" && -z "${VIQO_MODEL:-}" ]]; then
    return 0
  fi

  if command -v node >/dev/null 2>&1; then
    node - <<'NODE'
const payload = {
  env: {},
};
if (process.env.ANTHROPIC_BASE_URL) {
  payload.env.ANTHROPIC_BASE_URL = process.env.ANTHROPIC_BASE_URL;
  payload.env.VIQO_BASE_URL = process.env.VIQO_BASE_URL || process.env.ANTHROPIC_BASE_URL;
}
if (process.env.VIQO_MODEL) {
  payload.env.VIQO_MODEL = process.env.VIQO_MODEL;
  payload.model = process.env.VIQO_MODEL;
  payload.availableModels = [process.env.VIQO_MODEL];
}
process.stdout.write(JSON.stringify(payload));
NODE
    return 0
  fi

  printf '{"env":{"ANTHROPIC_BASE_URL":"%s","VIQO_BASE_URL":"%s","VIQO_MODEL":"%s"},"model":"%s","availableModels":["%s"]}' \
    "${ANTHROPIC_BASE_URL:-}" \
    "${VIQO_BASE_URL:-${ANTHROPIC_BASE_URL:-}}" \
    "${VIQO_MODEL:-}" \
    "${VIQO_MODEL:-}" \
    "${VIQO_MODEL:-}"
}
