#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "▸ Installing lighthouse-command into: $TARGET_DIR"

# ── Detect package manager ──────────────────────────────────────
PM="npm"
if command -v bun &>/dev/null; then
  PM="bun"
elif command -v pnpm &>/dev/null; then
  PM="pnpm"
elif command -v yarn &>/dev/null; then
  PM="yarn"
fi
echo "▸ Package manager detected: $PM"

# ── 1. Copy scripts ─────────────────────────────────────────────
mkdir -p "$TARGET_DIR/scripts"
cp "$REPO_DIR/scripts/lighthouse-audit.ts" "$TARGET_DIR/scripts/lighthouse-audit.ts"
cp "$REPO_DIR/scripts/lighthouse-summary.ts" "$TARGET_DIR/scripts/lighthouse-summary.ts"
echo "▸ ✓ scripts/lighthouse-*.ts copied"

# ── 2. Copy OpenCode command ────────────────────────────────────
mkdir -p "$TARGET_DIR/.opencode/commands"
cp "$REPO_DIR/command/commands/lighthouse.md" "$TARGET_DIR/.opencode/commands/lighthouse.md"
echo "▸ ✓ .opencode/commands/lighthouse.md copied"

# ── 3. Copy OpenCode tool ───────────────────────────────────────
mkdir -p "$TARGET_DIR/.opencode/tools"
cp "$REPO_DIR/command/tools/run-lighthouse.ts" "$TARGET_DIR/.opencode/tools/run-lighthouse.ts"
echo "▸ ✓ .opencode/tools/run-lighthouse.ts copied"

# ── 4. Copy prompt ──────────────────────────────────────────────
mkdir -p "$TARGET_DIR/.opencode/prompts"
cp "$REPO_DIR/command/prompts/lighthouse-fix.md" "$TARGET_DIR/.opencode/prompts/lighthouse-fix.md"
echo "▸ ✓ .opencode/prompts/lighthouse-fix.md copied"

# ── 5. Install dependencies ─────────────────────────────────────
echo "▸ Installing lighthouse + @opencode-ai/plugin..."
case "$PM" in
  bun)  bun add -D lighthouse @opencode-ai/plugin ;;
  pnpm) pnpm add -D lighthouse @opencode-ai/plugin ;;
  yarn) yarn add -D lighthouse @opencode-ai/plugin ;;
  *)    npm install --save-dev lighthouse @opencode-ai/plugin ;;
esac
echo "▸ ✓ Dependencies installed"

# ── 6. Add npm scripts to package.json ─────────────────────────
if command -v jq &>/dev/null; then
  jq '.scripts["lighthouse:audit"] = "bun run scripts/lighthouse-audit.ts" |
      .scripts["lighthouse:summary"] = "bun run scripts/lighthouse-summary.ts" |
      .scripts["lighthouse:all"] = "bun run scripts/lighthouse-audit.ts && bun run scripts/lighthouse-summary.ts"' \
    "$TARGET_DIR/package.json" > "$TARGET_DIR/package.json.tmp" && mv "$TARGET_DIR/package.json.tmp" "$TARGET_DIR/package.json"
  echo "▸ ✓ npm scripts added to package.json"
else
  echo "▸ ⚠  jq not found. Add these scripts to your package.json manually:"
  echo '   "lighthouse:audit": "bun run scripts/lighthouse-audit.ts"'
  echo '   "lighthouse:summary": "bun run scripts/lighthouse-summary.ts"'
  echo '   "lighthouse:all": "bun run scripts/lighthouse-audit.ts && bun run scripts/lighthouse-summary.ts"'
fi

# ── 7. Add agent to opencode.json ───────────────────────────────
OPENCODE_CONFIG="$TARGET_DIR/opencode.json"
AGENT_CONFIG='{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "lighthouse-fix": {
      "prompt": "{file:./.opencode/prompts/lighthouse-fix.md}"
    }
  }
}'

if [ -f "$OPENCODE_CONFIG" ]; then
  # Merge agent config into existing opencode.json
  if command -v jq &>/dev/null; then
    jq '.agent["lighthouse-fix"] = {"prompt": "{file:./.opencode/prompts/lighthouse-fix.md}"}' \
      "$OPENCODE_CONFIG" > "$OPENCODE_CONFIG.tmp" && mv "$OPENCODE_CONFIG.tmp" "$OPENCODE_CONFIG"
    echo "▸ ✓ lighthouse-fix agent added to opencode.json"
  else
    echo "▸ ⚠  jq not found. Add this to your opencode.json manually:"
    echo '   "agent": { "lighthouse-fix": { "prompt": "{file:./.opencode/prompts/lighthouse-fix.md}" } }'
  fi
else
  echo "$AGENT_CONFIG" > "$OPENCODE_CONFIG"
  echo "▸ ✓ opencode.json created with lighthouse-fix agent"
fi

# ── 8. Add lighthouse-*.json to .gitignore ──────────────────────
GITIGNORE="$TARGET_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
  if ! grep -q "lighthouse-\*.json" "$GITIGNORE" 2>/dev/null; then
    echo -e "\n# lighthouse\nlighthouse-*.json" >> "$GITIGNORE"
    echo "▸ ✓ lighthouse-*.json added to .gitignore"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Lighthouse command installed!"
echo ""
echo "  Usage:"
echo "    1. Start your dev server:  $PM run dev"
echo "    2. In OpenCode, type:      /lighthouse"
echo ""
echo "  Or run manually:"
echo "    $PM run lighthouse:all"
echo ""
echo "  Targets: performance ≥ 90, accessibility ≥ 95,"
echo "           best-practices ≥ 95, seo ≥ 95"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
