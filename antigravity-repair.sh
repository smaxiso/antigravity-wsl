#!/usr/bin/env bash
set -e

# Detect latest VS Code server commit from local install
VS_COMMIT="$(ls -1 ~/.vscode-server/bin 2>/dev/null | head -n1)"

if [[ -z "$VS_COMMIT" ]]; then
    echo "❌ No VS Code server found in ~/.vscode-server/bin."
    echo "👉 Run 'code .' in WSL once to install the VS Code server."
    exit 1
fi

# Find only real directories that look like server installs (ignores tarballs)
AG_DIRS=$(find ~/.antigravity-server/bin -maxdepth 1 -mindepth 1 -type d 2>/dev/null)

if [[ -z "$AG_DIRS" ]]; then
  echo "❌ No Antigravity server directories found."
  echo "👉 Run 'agy .' once to let Antigravity create the directories (it will fail, that's expected)."
  exit 1
fi

echo "🔧 Repairing Antigravity WSL server..."
echo "   VS_COMMIT=$VS_COMMIT"

for AG_BASE in $AG_DIRS; do
  AG_COMMIT=$(basename "$AG_BASE")
  
  # Skip if it doesn't look like a server dir (must have product.json or bin)
  if [[ ! -f "$AG_BASE/product.json" && ! -e "$AG_BASE/bin" ]]; then
      continue
  fi

  echo "   → Patching $AG_COMMIT"

  # 1. If bin is a symlink (the bug), replace it with a real directory
  if [[ -L "$AG_BASE/bin" ]]; then
    rm "$AG_BASE/bin"
    mkdir -p "$AG_BASE/bin"
  fi

  # 2. Ensure remote-cli path exists
  mkdir -p "$AG_BASE/bin/remote-cli"

  # 3. Link the binary
  ln -sf \
    "$HOME/.vscode-server/bin/$VS_COMMIT/bin/remote-cli/code" \
    "$AG_BASE/bin/remote-cli/antigravity"
done

echo "✔ Antigravity WSL server repaired"
