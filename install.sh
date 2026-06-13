#!/bin/bash
# Moon Installer for Termux
# Usage: curl -fsSL https://raw.githubusercontent.com/YOU/moon/main/install.sh | bash

set -e

CY="\033[36m"
GRN="\033[32m"
DIM="\033[90m"
RED="\033[31m"
WB="\033[97m"
RST="\033[0m"

REPO="https://raw.githubusercontent.com/YOU/moon/main"
DEST="$HOME/moon"

echo -e "\n${CY}  Installing Moon...${RST}\n"

# ── Check Termux ──────────────────────────────────────────────────────────────
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}  ✗ Moon requires Termux on Android${RST}"
    exit 1
fi

# ── Dependencies ──────────────────────────────────────────────────────────────
echo -e "${DIM}  · checking dependencies...${RST}"
pkg install -y python git curl 2>/dev/null | tail -1
pip install -q --break-system-packages requests 2>/dev/null || true

# ── Download Moon ─────────────────────────────────────────────────────────────
echo -e "${DIM}  · downloading Moon...${RST}"

# Remove old install if exists
rm -rf "$DEST"
mkdir -p "$DEST"/{ai,core,config,workspace}

# Files to download
FILES=(
    "main.py"
    "requirements.txt"
    "ai/__init__.py"
    "ai/assistant.py"
    "ai/router.py"
    "ai/openrouter_client.py"
    "core/__init__.py"
    "core/context_engine.py"
    "core/file_manager.py"
    "core/project_scanner.py"
    "core/analyser.py"
    "core/cost_tracker.py"
    "core/git_context.py"
    "core/test_runner.py"
    "config/__init__.py"
    "config/settings.py"
    "config/api_key.env.example"
)

for file in "${FILES[@]}"; do
    dir=$(dirname "$DEST/$file")
    mkdir -p "$dir"
    curl -fsSL "$REPO/$file" -o "$DEST/$file" 2>/dev/null
done

touch "$DEST/workspace/.gitkeep"

# ── Set up API key ────────────────────────────────────────────────────────────
echo -e "\n${WB}  OpenRouter API key required (get one free at openrouter.ai)${RST}"
printf "${CY}  Enter your API key: ${RST}"
read -r API_KEY

if [ -n "$API_KEY" ]; then
    mkdir -p "$DEST/config"
    echo "OPENROUTER_API_KEY=$API_KEY" > "$DEST/config/api_key.env"
    echo -e "${GRN}  ✓ API key saved${RST}"
else
    echo -e "${DIM}  · skipped — add it later to ~/moon/config/api_key.env${RST}"
fi

# ── Install moon command ──────────────────────────────────────────────────────
echo -e "${DIM}  · setting up moon command...${RST}"

SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

# Remove old alias if exists
grep -v "alias moon=" "$SHELL_RC" > /tmp/rc_tmp 2>/dev/null && mv /tmp/rc_tmp "$SHELL_RC" || true

# Add new alias
echo "" >> "$SHELL_RC"
echo "# Moon Terminal IDE" >> "$SHELL_RC"
echo "alias moon='python \$HOME/moon/main.py'" >> "$SHELL_RC"

# Make it available immediately in current session
export PATH="$PATH:$HOME/moon"

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "\n${GRN}  ✓ Moon installed successfully!${RST}"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}"
echo -e "  Type ${CY}moon${RST} to start — you may need to restart Termux first"
echo -e "  Type ${CY}moon --help${RST} or ${CY}?${RST} inside Moon for commands"
echo -e "${DIM}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RST}\n"

# Try to source rc file so moon works immediately
source "$SHELL_RC" 2>/dev/null || true
