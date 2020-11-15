#!/usr/bin/env bash
set -euo pipefail

echo "Creating symlink"
ln -s "${PWD}/map-tiles" ~/.local/bin/map-tiles

echo "Done."
