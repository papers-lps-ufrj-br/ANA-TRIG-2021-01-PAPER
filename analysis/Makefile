SHELL := /bin/bash

# Configuration
ENV_NAME := ringer-paper
ACTIVATE := source activate.sh

.PHONY: install build jupyter clean all env-rm

all: build

# Install environment and package
install:
	@echo "🛠️  Creating/Updating conda environment from environment.yml..."
	@conda env create -f environment.yml || conda env update -n $(ENV_NAME) -f environment.yml
	@echo "🛠️  Installing package in editable mode..."
	@echo "✅ Installation complete."

# Delete the conda environment
env-rm:
	@echo "🔥 Removing conda environment: $(ENV_NAME)..."
	@conda env remove -n $(ENV_NAME) -y || true
	@echo "✨ Environment removed."

# Build target to install the current package in editable mode
build:
	@echo "🛠️  Installing package in editable mode..."
	@$(ACTIVATE) && pip install -e .

# Launch Jupyter Lab within the conda environment
jupyter:
	@echo "🚀 Launching Jupyter Lab..."
	@$(ACTIVATE) && jupyter lab --IdentityProvider.token="" --ServerApp.password=""

clean: env-rm
	@echo "🧹 Cleaning up legacy files..."
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.pyd" -delete
	find . -type f -name ".DS_Store" -delete
	@echo "✨ Done!"