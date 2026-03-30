#!/usr/bin/env bash
#
# sync-upstream.sh
#
# Synchronisiert das developer-kit-core Plugin vom Original-Repository
# (giuseppe-trisciuoglio/developer-kit) und aktualisiert das Copilot-Manifest.
#
# Usage:
#   ./scripts/sync-upstream.sh              # Sync ausfuehren
#   ./scripts/sync-upstream.sh --dry-run    # Nur Aenderungen anzeigen
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_REPO="https://github.com/giuseppe-trisciuoglio/developer-kit.git"
UPSTREAM_PLUGIN="plugins/developer-kit-core"
TMP_DIR="$(mktemp -d)"
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
  esac
done

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "=== Developer Kit Copilot - Upstream Sync ==="
echo ""

# 1. Original klonen
echo "[1/4] Klone upstream: $UPSTREAM_REPO"
git clone --depth 1 --quiet "$UPSTREAM_REPO" "$TMP_DIR/upstream"

UPSTREAM_SRC="$TMP_DIR/upstream/$UPSTREAM_PLUGIN"
LOCAL_DST="$REPO_ROOT/$UPSTREAM_PLUGIN"

if [ ! -d "$UPSTREAM_SRC" ]; then
  echo "FEHLER: $UPSTREAM_PLUGIN nicht im upstream gefunden!"
  exit 1
fi

# 2. Aenderungen pruefen
echo "[2/4] Pruefe Aenderungen..."

# Kopiere upstream in temp-Vergleichsordner (ohne .github/)
COMPARE_DIR="$TMP_DIR/compare"
mkdir -p "$COMPARE_DIR"
rsync -a --exclude='.github/' "$UPSTREAM_SRC/" "$COMPARE_DIR/"

# Vergleiche mit lokalem Stand (ohne .github/ und .DS_Store)
DIFF_OUTPUT=$(diff -rq \
  --exclude='.github' \
  --exclude='.DS_Store' \
  "$COMPARE_DIR" "$LOCAL_DST" 2>/dev/null || true)

if [ -z "$DIFF_OUTPUT" ]; then
  echo ""
  echo "Keine Aenderungen. Plugin ist aktuell."
  exit 0
fi

echo ""
echo "Gefundene Aenderungen:"
echo "$DIFF_OUTPUT" | head -30
CHANGE_COUNT=$(echo "$DIFF_OUTPUT" | wc -l | tr -d ' ')
echo ""
echo "Gesamt: $CHANGE_COUNT Datei(en) geaendert."

if [ "$DRY_RUN" = true ]; then
  echo ""
  echo "[Dry Run] Keine Aenderungen geschrieben."
  exit 0
fi

# 3. Dateien synchronisieren
echo ""
echo "[3/4] Synchronisiere Dateien..."

# Alle Plugin-Inhalte kopieren (agents, commands, skills, hooks, docs, README)
# .claude-plugin/ wird auch kopiert (ist das Original-Manifest)
rsync -a \
  --exclude='.github/' \
  --exclude='.DS_Store' \
  --delete \
  "$UPSTREAM_SRC/" "$LOCAL_DST/"

# .github/plugin.json aus .claude-plugin/plugin.json generieren
echo "[3/4] Aktualisiere Copilot-Manifest (.github/plugin.json)..."
mkdir -p "$LOCAL_DST/.github"
cp "$LOCAL_DST/.claude-plugin/plugin.json" "$LOCAL_DST/.github/plugin.json"

# 4. Upstream-Version auslesen
UPSTREAM_VERSION=$(python3 -c "
import json, sys
with open('$LOCAL_DST/.claude-plugin/plugin.json') as f:
    print(json.load(f).get('version', 'unknown'))
" 2>/dev/null || echo "unknown")

echo ""
echo "[4/4] Sync abgeschlossen."
echo ""
echo "  Upstream-Version: $UPSTREAM_VERSION"
echo "  Geaenderte Dateien: $CHANGE_COUNT"
echo ""
echo "Naechste Schritte:"
echo "  git diff                    # Aenderungen pruefen"
echo "  git add -A && git commit    # Committen"
echo "  git push                    # Pushen"
