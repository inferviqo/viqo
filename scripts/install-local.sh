#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "==> Installing dependencies..."
npm install

echo "==> Making viqo executable..."
chmod +x bin/viqo

echo "==> Linking compatibility paths for the underlying CLI runtime..."
bash scripts/link-compat.sh

echo "==> Linking viqo globally (npm link -g)..."
npm link

echo ""
echo "Viqo installed locally."
echo ""
echo "Apply default API URL to your user settings (run once):"
echo "  npm run configure"
echo ""
echo "Configure your API key (one-time):"
echo "  cp viqo.config.local.json.example viqo.config.local.json"
echo "  # then edit viqo.config.local.json with your key"
echo ""
echo "Default API URL: https://api.inferviqo.com (edit viqo.config.json to change)"
echo ""
echo "Verify:"
echo "  viqo --version"
echo ""
echo "Register this repo's plugin marketplace (run once):"
echo "  viqo plugin marketplace add \"$ROOT\""
echo ""
echo "Then install plugins, for example:"
echo "  viqo plugin install commit-commands@viqo-plugins"
echo ""
echo "Or load plugins directly from this repo:"
echo "  viqo --plugin-dir \"$ROOT/plugins/commit-commands\""
