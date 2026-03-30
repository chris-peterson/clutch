#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

echo "Installing clutch..."

# Add to .zshrc if not already present
if ! grep -q 'clutch.zsh' "$ZSHRC" 2>/dev/null; then
  cat >> "$ZSHRC" <<EOF

# clutch — Claude tab-completion and utilities
fpath=("$SCRIPT_DIR" \$fpath)
source "$SCRIPT_DIR/clutch.zsh"
autoload -Uz compinit && compinit
EOF
  echo "Added clutch to $ZSHRC"
else
  echo "clutch already in $ZSHRC"
fi

echo "Done. Restart your shell or run: source $ZSHRC"
