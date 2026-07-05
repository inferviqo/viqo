#!/usr/bin/env bash
# Merge Viqo API defaults into ~/.claude/settings.json (run once).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="${HOME}/.claude/settings.json"
CONFIG="$ROOT/viqo.config.json"

mkdir -p "$(dirname "$SETTINGS")"

python3 - "$SETTINGS" "$CONFIG" <<'PY'
import json
import sys
from pathlib import Path

settings_path = Path(sys.argv[1])
config_path = Path(sys.argv[2])

api_url = "https://api.inferviqo.com"
if config_path.is_file():
    try:
        api_url = json.loads(config_path.read_text()).get("apiBaseUrl") or api_url
    except json.JSONDecodeError:
        pass

if settings_path.is_file():
    data = json.loads(settings_path.read_text())
else:
    data = {}

data.setdefault("env", {})
data["env"]["ANTHROPIC_BASE_URL"] = api_url
data["env"]["VIQO_BASE_URL"] = api_url

settings_path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated {settings_path}")
print(f"  ANTHROPIC_BASE_URL={api_url}")
print(f"  VIQO_BASE_URL={api_url}")
PY

echo ""
echo "Add your API key:"
echo "  cp viqo.config.local.json.example viqo.config.local.json"
echo "  # edit viqo.config.local.json — or export ANTHROPIC_API_KEY / VIQO_API_KEY"
