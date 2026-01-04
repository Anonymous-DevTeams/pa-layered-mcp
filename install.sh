#!/bin/bash
# PA-Retriever Install Script
# Usage: curl -sSL https://pa-layer.github.io/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║       PA-Retriever Installer             ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

case "$OS" in
    darwin)
        OS="darwin"
        ;;
    linux)
        OS="linux"
        ;;
    mingw*|msys*|cygwin*)
        echo -e "${YELLOW}Windows detected. Please use the PowerShell installer or Scoop.${NC}"
        echo ""
        echo "Scoop:"
        echo "  scoop bucket add pa-layer https://github.com/pa-layer/scoop-bucket"
        echo "  scoop install pa-retriever"
        exit 1
        ;;
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

echo -e "Detected: ${GREEN}$OS-$ARCH${NC}"
echo ""

# Get latest version
echo -e "${YELLOW}Fetching latest version...${NC}"
LATEST_VERSION=$(curl -sL https://api.github.com/repos/pa-layer/pa-retriever/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    LATEST_VERSION="v0.8.0"  # fallback
fi

echo -e "Latest version: ${GREEN}$LATEST_VERSION${NC}"
echo ""

# Download URL
FILENAME="pa-retriever-${OS}-${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/pa-layer/pa-retriever/releases/download/${LATEST_VERSION}/${FILENAME}"

# Install directory
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Download
echo -e "${YELLOW}Downloading ${FILENAME}...${NC}"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if command -v curl &> /dev/null; then
    curl -sLO "$DOWNLOAD_URL"
elif command -v wget &> /dev/null; then
    wget -q "$DOWNLOAD_URL"
else
    echo -e "${RED}Neither curl nor wget found. Please install one of them.${NC}"
    exit 1
fi

# Extract
echo -e "${YELLOW}Extracting...${NC}"
tar xzf "$FILENAME"

# Install
echo -e "${YELLOW}Installing to ${INSTALL_DIR}...${NC}"
chmod +x pa
mv pa "$INSTALL_DIR/"

# Cleanup
cd -
rm -rf "$TEMP_DIR"

# Check PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo -e "${YELLOW}Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):${NC}"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi

# Verify
echo ""
if command -v "$INSTALL_DIR/pa" &> /dev/null; then
    echo -e "${GREEN}✅ Installation complete!${NC}"
    echo ""
    "$INSTALL_DIR/pa" version
    echo ""
    echo -e "Next steps:"
    echo -e "  ${BLUE}pa init${NC}         Initialize PA-Retriever"
    echo -e "  ${BLUE}pa index${NC}        Index your documents"
    echo -e "  ${BLUE}pa mcp install${NC}  Connect with Claude"
else
    echo -e "${RED}Installation may have failed. Please check manually.${NC}"
    exit 1
fi
