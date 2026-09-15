#!/bin/bash

# ==============================================================================
# Miniconda Installation Script
# This script downloads and installs the latest Miniconda for Linux.
# ==============================================================================

set -e

# Default installation directory
DEFAULT_PATH="$HOME/miniconda3"
INSTALL_PATH=${1:-$DEFAULT_PATH}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==>${NC} Starting Miniconda installation process..."

# Check if conda is already installed
if command -v conda &> /dev/null; then
    echo -e "${GREEN}==>${NC} Conda is already installed at: $(which conda)"
    exit 0
fi

# Determine architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  OS_ARCH="x86_64" ;;
    aarch64) OS_ARCH="aarch64" ;;
    *)
        echo -e "${RED}Error:${NC} Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-${OS_ARCH}.sh"

echo -e "${BLUE}==>${NC} Detected architecture: ${OS_ARCH}"
echo -e "${BLUE}==>${NC} Target directory: ${INSTALL_PATH}"

# Prepare temporary directory
TMP_DIR=$(mktemp -d)
INSTALLER="$TMP_DIR/miniconda_installer.sh"

# Download installer
echo -e "${BLUE}==>${NC} Downloading Miniconda installer..."
if ! wget -q --show-progress -O "$INSTALLER" "$MINICONDA_URL"; then
    echo -e "${RED}Error:${NC} Failed to download installer from $MINICONDA_URL"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Run installer in batch mode
echo -e "${BLUE}==>${NC} Installing Miniconda (this may take a moment)..."
bash "$INSTALLER" -b -u -p "$INSTALL_PATH"

# Cleanup
rm -rf "$TMP_DIR"

# Initialize conda for the current shell
echo -e "${BLUE}==>${NC} Initializing Conda..."
"$INSTALL_PATH/bin/conda" init bash

echo -e "\n${GREEN}Successfully installed Miniconda!${NC}"
echo -e "To start using conda, please restart your terminal or run:"
echo -e "  ${BLUE}source ~/.bashrc${NC}\n"