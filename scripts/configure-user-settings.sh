#!/usr/bin/env bash
# Merge Viqo API defaults into ~/.claude/settings.json (run once).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS="${HOME}/.claude/settings.json"
CONFIG="$ROOT/viqo.config.json"

mkdir -p "$(dirname "$SETTINGS")"

node - "$SETTINGS" "$CONFIG" <<'NODE'
const fs = require("fs");
const path = require("path");

const settingsPath = process.argv[2];
const configPath = process.argv[3];

let apiUrl = "https://api.inferviqo.com";
let model = "accounts/fireworks/models/gpt-oss-20b";

if (fs.existsSync(configPath)) {
  try {
    const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
    apiUrl = config.apiBaseUrl || apiUrl;
    model = config.model || model;
  } catch {
    // keep defaults
  }
}

apiUrl = apiUrl.replace(/\/+$/, "");
while (apiUrl.endsWith("/v1")) {
  apiUrl = apiUrl.slice(0, -3);
}

let data = {};
if (fs.existsSync(settingsPath)) {
  data = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
}

data.env = data.env || {};
data.env.ANTHROPIC_BASE_URL = apiUrl;
data.env.VIQO_BASE_URL = apiUrl;
data.env.VIQO_MODEL = model;
data.model = model;
data.availableModels = [model];
delete data.modelOverrides;
for (const key of Object.keys(data.env)) {
  if (key.startsWith("VIQO_DEFAULT_")) {
    delete data.env[key];
  }
}

fs.writeFileSync(settingsPath, JSON.stringify(data, null, 2) + "\n");
console.log(`Updated ${settingsPath}`);
console.log(`  ANTHROPIC_BASE_URL=${apiUrl}`);
console.log(`  VIQO_BASE_URL=${apiUrl}`);
console.log(`  VIQO_MODEL=${model}`);
NODE

echo ""
echo "Add your API key:"
echo "  cp viqo.config.local.json.example viqo.config.local.json"
echo "  # edit viqo.config.local.json — or export ANTHROPIC_API_KEY / VIQO_API_KEY"
