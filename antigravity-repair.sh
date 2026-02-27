#!/usr/bin/env bash
set -e

# Detect local VS Code commit
VS_COMMIT="$(ls -1 ~/.vscode-server/bin 2>/dev/null | head -n1)"
if [[ -z "$VS_COMMIT" ]]; then
    echo "❌ No VS Code server found. Run 'code .' first."
    exit 1
fi

AG_BIN_DIR="$HOME/.antigravity-server/bin"
mkdir -p "$AG_BIN_DIR"

# 1. ALWAYS check for failed downloads (tarballs) FIRST.
FAILED_TAR=$(ls -1 "$AG_BIN_DIR"/*.tar.gz 2>/dev/null | head -n1)

if [[ -n "$FAILED_TAR" ]]; then
    FILENAME=$(basename "$FAILED_TAR")
    RECOVERED_COMMIT="${FILENAME:0:40}"

    echo "⚠️  Update detected! Found failed download artifact: $FILENAME"
    echo "🧹 Cleaning up old server cache..."
    
    # Delete old server directories to prevent update loops
    find "$AG_BIN_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
    
    echo "🔨 Force-creating directory for new commit: $RECOVERED_COMMIT"
    mkdir -p "$AG_BIN_DIR/$RECOVERED_COMMIT"

    # Cleanup the bad file
    rm -f "$FAILED_TAR"
fi

# 2. Gather directories
AG_DIRS=$(find "$AG_BIN_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)

if [[ -z "$AG_DIRS" ]]; then
  echo "❌ No Antigravity directories or artifacts found."
  echo "👉 Run 'agy .' once to generate them."
  exit 1
fi

echo "🔧 Repairing Antigravity WSL server..."
echo "   VS_COMMIT=$VS_COMMIT"

for AG_BASE in $AG_DIRS; do
  AG_COMMIT=$(basename "$AG_BASE")

  # Skip non-server dirs
  if [[ ! -f "$AG_BASE/product.json" && ! -e "$AG_BASE/bin" && "$AG_BASE" != *"$RECOVERED_COMMIT"* ]]; then
      continue
  fi

  echo "   → Patching $AG_COMMIT"

  # 1. Fix symlink bug
  if [[ -L "$AG_BASE/bin" ]]; then
    rm "$AG_BASE/bin"
    mkdir -p "$AG_BASE/bin"
  fi

  # 2. Create structure
  mkdir -p "$AG_BASE/bin/remote-cli"

  # 3. Link binaries
  ln -sf \
    "$HOME/.vscode-server/bin/$VS_COMMIT/bin/remote-cli/code" \
    "$AG_BASE/bin/remote-cli/antigravity"
done

echo ""
echo "=================================================="
echo "✔ Antigravity WSL server successfully repaired! 🚀"
echo "=================================================="
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "1. Open Windows PowerShell and run: wsl --shutdown"
echo "2. Re-open your Ubuntu terminal."
echo "3. Run 'agy .' again."
echo ""
