#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
if echo "$HERE" | grep -v '^/'; then
    HERE="$(pwd)/$HERE"
fi
source "$HERE/env/bin/activate"

python "$HERE/stable_diffusion/demo.py" "$@"