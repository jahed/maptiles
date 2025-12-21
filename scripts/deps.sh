#!/usr/bin/env bash
set -exuo pipefail

apt update
apt install imagemagick pngquant

echo "Done."
