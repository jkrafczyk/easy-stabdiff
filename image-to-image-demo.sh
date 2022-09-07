#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
mkdir -p input output

if [[ $# -ne 2 ]]; then
    cat <<EOF
$0 - Run image-to-image generation with various parameters for comparison

Usage: $0 image-basename prompt

Examples:

EOF
    exit 1
fi

NAME=$1
PROMPT=$2
RUN_NAME="i2i-demo-$(date +%s)"
for idx in 1 2 3; do
    SEED=$RANDOM
    for STRENGTH in 4 5 6 7; do
        ATTEMPT_NAME="$RUN_NAME-seed-$SEED-strength-0.$STRENGTH"
        $HERE/image-to-image.sh \
            "$NAME" \
            "$ATTEMPT_NAME" \
            "$PROMPT" \
            --seed "$SEED" \
            --num-inference-steps 64 \
            --strength 0.$STRENGTH 
    done
done