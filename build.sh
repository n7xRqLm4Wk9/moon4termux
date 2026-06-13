#!/bin/bash
# Moon Build Script — obfuscates source and prepares dist for distribution
set -e

CY="\033[36m"
GRN="\033[32m"
DIM="\033[90m"
RED="\033[31m"
RST="\033[0m"

SRC="$HOME/moon"
OUT="/sdcard/moon_dist"

echo -e "\n${CY}  Moon Build${RST}  ${DIM}obfuscating source...${RST}\n"

# ── Check pyarmor installed ───────────────────────────────────────────────────
if ! command -v pyarmor &>/dev/null; then
    echo -e "${DIM}  · installing pyarmor...${RST}"
    pip install pyarmor --break-system-packages -q
fi

# ── Clean old dist ────────────────────────────────────────────────────────────
rm -rf "$OUT"
mkdir -p "$OUT"

# ── Obfuscate ─────────────────────────────────────────────────────────────────
echo -e "${DIM}  · obfuscating...${RST}"
cd "$SRC"
pyarmor gen -O "$OUT" \
    main.py \
    ai/assistant.py \
    ai/router.py \
    ai/openrouter_client.py \
    core/context_engine.py \
    core/file_manager.py \
    core/project_scanner.py \
    core/analyser.py \
    core/cost_tracker.py \
    core/git_context.py \
    core/test_runner.py \
    config/settings.py \
    2>/dev/null

# ── Copy non-py files ─────────────────────────────────────────────────────────
echo -e "${DIM}  · copying assets...${RST}"
cp requirements.txt "$OUT/"
cp config/api_key.env.example "$OUT/config/" 2>/dev/null || true
cp .gitignore "$OUT/" 2>/dev/null || true

# Copy __init__.py files (not obfuscated, they're empty)
for d in ai core config; do
    mkdir -p "$OUT/$d"
    cp "$d/__init__.py" "$OUT/$d/__init__.py" 2>/dev/null || touch "$OUT/$d/__init__.py"
done

mkdir -p "$OUT/workspace"
touch "$OUT/workspace/.gitkeep"

# ── Write install.sh into dist ────────────────────────────────────────────────
cp "$SRC/install.sh" "$OUT/install.sh" 2>/dev/null || true

echo -e "${GRN}  ✓ build complete${RST}  ${DIM}→ /sdcard/moon_dist${RST}"
echo -e "${DIM}  push /sdcard/moon_dist to your GitHub repo${RST}\n"
