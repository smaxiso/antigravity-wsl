
#!/usr/bin/env bash
set -e

# Detect local VS Code commit
VS_COMMIT="$(ls -1 ~/.vscode-server/bin 2>/dev/null | head -n1)"
if [[ -z "$VS_COMMIT" ]]; then
    echo "❌ No VS Code server found. Run 'code .' first."
    exit 1
fi

AG_BIN_DIR="$HOME/.antigravity-server/bin"
# Find real directories
AG_DIRS=$(find "$AG_BIN_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null || true)

# FALLBACK: If no directories, check for failed tarballs
if [[ -z "$AG_DIRS" ]]; then
    # Look for files like <COMMIT>-<TIMESTAMP>.tar.gz
    FAILED_TAR=$(ls -1 "$AG_BIN_DIR"/*.tar.gz 2>/dev/null | head -n1)

    if [[ -n "$FAILED_TAR" ]]; then
        FILENAME=$(basename "$FAILED_TAR")
        # Extract the first 40 chars (the commit hash)
        RECOVERED_COMMIT="${FILENAME:0:40}"

        echo "⚠️  Found failed download artifact: $FILENAME"
        echo "🔨 Force-creating directory for commit: $RECOVERED_COMMIT"

        mkdir -p "$AG_BIN_DIR/$RECOVERED_COMMIT"
        AG_DIRS="$AG_BIN_DIR/$RECOVERED_COMMIT"

        # Cleanup the bad file
        rm -f "$FAILED_TAR"
    fi
fi

if [[ -z "$AG_DIRS" ]]; then
  echo "❌ No Antigravity directories or artifacts found."
  echo "👉 Run 'agy .' once to generate them."
  exit 1
fi

echo "🔧 Repairing Antigravity WSL server..."
echo "   VS_COMMIT=$VS_COMMIT"

for AG_BASE in $AG_DIRS; do
  AG_COMMIT=$(basename "$AG_BASE")

  # Skip non-server dirs (safety check)
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

echo "✔ Antigravity WSL server repaired"
