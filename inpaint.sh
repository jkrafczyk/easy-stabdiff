#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
mkdir -p input output

if [[ $# -lt 3 ]]; then
    cat <<EOF
$0 - Perform image inpainting with stable diffusion

Usage: $0 image-basename attempt-name prompt [addition args to diffuse.sh]

Examples:
Inpaint 'input/foo.jpg' with the mask 'input/foo-mask.png', mark as attempt 2,
use the prompt "Awesome astronaut in space", and only run for 10 inference steps:

$0 connery my-first-inpainting "An awesome old astronaut in space" --num-inference-steps 64 --strenght 0.9
EOF
    exit 1
fi

NAME=$1
ATTEMPT=${2:-0}
PROMPT=$3
shift 3


INPUT="input/$NAME.jpg"
MASK="input/$NAME-mask.png"
OUTPUT_A="output/$NAME-$ATTEMPT-a.png"
OUTPUT_B="output/$NAME-$ATTEMPT-b.png"

error=0
if [[ ! -f "$INPUT" ]]; then
    >&2 echo "Input image $INPUT not found."
    error=1
fi
if [[ ! -f "$MASK" ]]; then
    >&2 echo "Mask image $MASK not found."
    error=1
fi
if [[ -z "$PROMPT" ]]; then
    >&2 echo "Prompt is empty."
    error=1
fi
if [[ $error -ne 0 ]]; then
    exit 1
fi

if [[ -f "$OUTPUT_A" ]]; then
    echo "Skipping infill, temp file already exists."
else 
    $HERE/diffuse.sh \
        --init-image "$INPUT" \
        --mask "$MASK" \
        --output "$OUTPUT_A" \
        --prompt "$PROMPT" \
        "$@"
fi

$HERE/diffuse.sh \
    --init-image "$OUTPUT_A" \
    --strength 0.10 \
    --num-inference-steps 150 \
    --output "$OUTPUT_B" \
    --prompt "$PROMPT"
