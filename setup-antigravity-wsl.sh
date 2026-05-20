#!/bin/bash
###############################################################################
# Antigravity IDE WSL Setup Script
#
# Automates the setup of Google Antigravity IDE to work seamlessly with WSL.
# Run this from your WSL terminal: bash setup-antigravity-wsl.sh
#
# What it does:
# 1. Creates 'agy' symlink for launching Antigravity IDE from WSL
# 2. Patches Antigravity IDE config to use correct WSL extension
# 3. Copies helper scripts from VS Code to Antigravity IDE
# 4. Enables mirrored networking for browser subagent
#
# Author: Sumit Kumar (smaxiso)
# Blog: https://smaxiso.web.app/blog/google-antigravity-wsl-guide
# GitHub: https://github.com/smaxiso
# License: MIT
###############################################################################

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Antigravity IDE WSL Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Detect Windows environment paths automatically
echo -e "${YELLOW}[1/6] Detecting Windows environment paths...${NC}"

WIN_LOCAL_APP=$(cmd.exe /c "echo %LOCALAPPDATA%" 2>/dev/null | tr -d '\r')
WIN_USER_PROFILE=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')

if [ -z "$WIN_LOCAL_APP" ] || [ -z "$WIN_USER_PROFILE" ]; then
    echo -e "${RED}❌ Could not detect Windows environment paths${NC}"
    echo "Please run this script from a standard WSL terminal"
    exit 1
fi

# Convert to native WSL mount paths
LOCAL_APP_WSL=$(wslpath "$WIN_LOCAL_APP")
USER_PROFILE_WSL=$(wslpath "$WIN_USER_PROFILE")

echo -e "${GREEN}✓ Environment paths detected successfully${NC}"
echo ""

# Define paths for the new Antigravity IDE architecture
ANTIGRAVITY_BIN="$LOCAL_APP_WSL/Programs/Antigravity IDE/bin/antigravity-ide"
ANTIGRAVITY_SCRIPTS="$LOCAL_APP_WSL/Programs/Antigravity IDE/resources/app/extensions/antigravity-remote-wsl/scripts"
VSCODE_EXTENSIONS="$USER_PROFILE_WSL/.vscode/extensions"
WSLCONFIG="$USER_PROFILE_WSL/.wslconfig"
LOCAL_BIN="$HOME/.local/bin"

# Step 1: Create symlink
echo -e "${YELLOW}[2/6] Creating 'agy' symlink...${NC}"

if [ ! -f "$ANTIGRAVITY_BIN" ]; then
    echo -e "${RED}❌ Antigravity IDE not found at: $ANTIGRAVITY_BIN${NC}"
    echo "Please install Antigravity IDE first"
    exit 1
fi

# Create ~/.local/bin if it doesn't exist
mkdir -p "$LOCAL_BIN"

# Create symlink (Overwrite old ones safely)
ln -sf "$ANTIGRAVITY_BIN" "$LOCAL_BIN/agy"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo -e "${YELLOW}⚠️  ~/.local/bin is not in your PATH${NC}"
    echo "Add this to your ~/.bashrc or ~/.zshrc:"
    echo -e "${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

echo -e "${GREEN}✓ Symlink created: agy -> Antigravity IDE${NC}"
echo ""

# Step 2: Patch Antigravity config
echo -e "${YELLOW}[3/6] Patching Antigravity IDE config...${NC}"

if [ ! -f "$ANTIGRAVITY_BIN" ]; then
    echo -e "${RED}❌ Config file not found${NC}"
    exit 1
fi

if [ ! -w "$ANTIGRAVITY_BIN" ]; then
    echo -e "${RED}❌ Config file is not writable${NC}"
    echo "Please check permissions for: $ANTIGRAVITY_BIN"
    exit 1
fi

# Check if already patched
if grep -q 'WSL_EXT_ID="google.antigravity-remote-wsl"' "$ANTIGRAVITY_BIN" 2>/dev/null; then
    echo -e "${GREEN}✓ Already patched (google.antigravity-remote-wsl)${NC}"
else
    # Check if the target string exists
    if grep -q 'WSL_EXT_ID="ms-vscode-remote.remote-wsl"' "$ANTIGRAVITY_BIN"; then
        # Create backup
        cp "$ANTIGRAVITY_BIN" "${ANTIGRAVITY_BIN}.backup"

        # Patch the file (replace MS extension with Google's)
        sed 's/WSL_EXT_ID="ms-vscode-remote.remote-wsl"/WSL_EXT_ID="google.antigravity-remote-wsl"/' "$ANTIGRAVITY_BIN" > "${ANTIGRAVITY_BIN}.tmp"

        if [ -s "${ANTIGRAVITY_BIN}.tmp" ]; then
            mv "${ANTIGRAVITY_BIN}.tmp" "$ANTIGRAVITY_BIN"

            # Verify patch
            if grep -q 'WSL_EXT_ID="google.antigravity-remote-wsl"' "$ANTIGRAVITY_BIN"; then
                echo -e "${GREEN}✓ Config patched successfully${NC}"
                echo -e "  Backup saved: ${ANTIGRAVITY_BIN}.backup"
            else
                echo -e "${RED}❌ Patch verification failed${NC}"
                echo "Please check content of: $ANTIGRAVITY_BIN"
            fi
        else
            echo -e "${RED}❌ Failed to create patched file${NC}"
            rm -f "${ANTIGRAVITY_BIN}.tmp"
        fi
    else
        echo -e "${RED}❌ Target configuration not found${NC}"
        echo "Could not find 'WSL_EXT_ID=\"ms-vscode-remote.remote-wsl\"' in config file."
        echo "The file format may have changed."
        exit 1
    fi
fi
echo ""

# Step 3: Copy helper scripts
echo -e "${YELLOW}[4/6] Copying helper scripts from VS Code...${NC}"

# Find latest VS Code WSL extension
VSCODE_WSL_EXT=$(find "$VSCODE_EXTENSIONS" -maxdepth 1 -name "ms-vscode-remote.remote-wsl-*" -type d | sort -V | tail -n 1)

if [ -z "$VSCODE_WSL_EXT" ]; then
    echo -e "${YELLOW}⚠️  VS Code WSL extension not found${NC}"
    echo "Install VS Code with WSL extension first, or skip this step"
else
    SOURCE_SCRIPTS="$VSCODE_WSL_EXT/scripts"

    if [ -d "$SOURCE_SCRIPTS" ]; then
        # Create destination directory if it doesn't exist
        mkdir -p "$ANTIGRAVITY_SCRIPTS"

        # Copy scripts
        cp -r "$SOURCE_SCRIPTS"/* "$ANTIGRAVITY_SCRIPTS/" 2>/dev/null || true

        echo -e "${GREEN}✓ Helper scripts copied${NC}"
        echo -e "  From: $(basename "$VSCODE_WSL_EXT")"
        echo -e "  To: antigravity-remote-wsl/scripts/"
    else
        echo -e "${YELLOW}⚠️  Scripts directory not found in VS Code extension${NC}"
    fi
fi
echo ""

# Step 4: Install repair tool
echo -e "${YELLOW}[5/6] Installing repair tool (antigravity-repair)...${NC}"

echo "⬇️ Installing auto-repair script..."
mkdir -p ~/.local/bin
# Download
curl -sL https://raw.githubusercontent.com/smaxiso/antigravity-wsl/master/antigravity-repair.sh -o ~/.local/bin/antigravity-repair
# 🛡️ Safety: Strip Windows line endings (CRLF) just in case
sed -i 's/\r$//' ~/.local/bin/antigravity-repair
# Make executable
chmod +x ~/.local/bin/antigravity-repair

echo "✅ Done! 'antigravity-repair' is now installed."
echo "👉 If 'agy' ever breaks after an update, just run: antigravity-repair"
echo ""

# Step 5: Setup mirrored networking
echo -e "${YELLOW}[6/6] Configuring mirrored networking...${NC}"

if [ -f "$WSLCONFIG" ]; then
    # Check if already configured
    if grep -q "networkingMode=mirrored" "$WSLCONFIG" 2>/dev/null; then
        echo -e "${GREEN}✓ Mirrored networking already enabled${NC}"
    else
        # Backup existing config
        cp "$WSLCONFIG" "${WSLCONFIG}.backup"

        # Add mirrored networking (append if [wsl2] section exists, create if not)
        if grep -q "\[wsl2\]" "$WSLCONFIG"; then
            # Add under [wsl2] section
            sed -i '/\[wsl2\]/a networkingMode=mirrored' "$WSLCONFIG"
        else
            # Create [wsl2] section
            echo -e "\n[wsl2]\nnetworkingMode=mirrored" >> "$WSLCONFIG"
        fi

        echo -e "${GREEN}✓ Mirrored networking enabled${NC}"
        echo -e "  Backup saved: ${WSLCONFIG}.backup"
    fi
else
    # Create new .wslconfig
    cat > "$WSLCONFIG" << 'EOF'
[wsl2]
networkingMode=mirrored
EOF
    echo -e "${GREEN}✓ Created .wslconfig with mirrored networking${NC}"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Restart WSL: Run ${BLUE}wsl --shutdown${NC} in PowerShell, then reopen WSL"
echo "2. Test the setup: Run ${BLUE}agy .${NC} from any project directory"
echo ""
echo -e "${YELLOW}Troubleshooting:${NC}"
echo "• If 'agy' command not found, add to PATH (see message above)"
echo "• If browser subagent fails, manually install Chrome extension"
echo "• After Antigravity IDE updates, re-run this script"
echo ""
echo -e "${BLUE}────────────────────────────────────────${NC}"
echo -e "📝 Full guide: ${BLUE}https://smaxiso.web.app/blog/google-antigravity-wsl-guide${NC}"
echo -e "👤 Created by: ${BLUE}Sumit Kumar (@smaxiso)${NC}"
echo -e "${BLUE}────────────────────────────────────────${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
