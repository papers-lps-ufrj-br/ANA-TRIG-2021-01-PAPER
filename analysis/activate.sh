#!/bin/bash

# ==============================================================================
# Conda Environment Activation & Auto-Install Script
# This script ensures conda is installed and the project environment is active.
# ==============================================================================

export ENV_NAME='ringer-paper'
export LOGURU_LEVEL=INFO
export CERN_DATA="/mnt/shared/storage03/projects/cern/data"


# 1. Check if conda command exists
if ! command -v conda &> /dev/null; then
    echo "Conda not found. Attempting to install Miniconda..."
    
    if [ -f "scripts/install_conda.sh" ]; then
        bash scripts/install_conda.sh
        
        # Try to initialize conda in the current session after install
        CONDA_PATH="$HOME/miniconda3"
        if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
            source "$CONDA_PATH/etc/profile.d/conda.sh"
        else
            echo "Error: Installation failed or path not found at $CONDA_PATH"
            return 1 2>/dev/null || exit 1
        fi
    else
        echo "Error: scripts/install_conda.sh not found."
        return 1 2>/dev/null || exit 1
    fi
fi

# 2. Initialize conda for the current shell session
# This handles the case where conda is installed but not active in this shell
eval "$(conda shell.bash hook)"

# 3. Check if project environment exists, if not, create it
if ! conda info --envs | grep -q "^$ENV_NAME "; then
    echo "Environment '$ENV_NAME' not found. Creating it now..."
    conda env create -f environment.yml
fi

# 4. Activate environment
echo "Activating conda environment: $ENV_NAME"
conda activate $ENV_NAME