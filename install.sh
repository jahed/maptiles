#!/usr/bin/env bash
set -euo pipefail

echo "Creating symlink"
ln -s "${PWD}/maptiles" ~/.local/bin/maptiles

echo "Done."
