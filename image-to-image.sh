#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
mkdir -p input output

if [[ $# -lt 3 ]]; then
    cat <<EOF
$0 - Perform image-to-image generation

Usage: $0 source-image attempt-name prompt [addition args to diffuse.sh]

Examples:
./image-to-image.sh tree-sky-grass-prompt 1 "Oil painting - A tree in the middle of a large grassy
 meadow with clear blue sky and the sun."
EOF
    exit 1
fi

NAME=$1
ATTEMPT=${2:-0}
PROMPT=$3
shift 3

if [[ -f "$NAME" ]]; then
    INPUT="$NAME"
    OUTPUT="output/$(basename $NAME)-$ATTEMPT.png"
elif [[ -f "input/$NAME.png" ]]; then
    INPUT="input/$NAME.png"
else
    INPUT="input/$NAME.jpg"
fi
OUTPUT="output/$NAME-$ATTEMPT.png"

error=0
if [[ ! -f "$INPUT" ]]; then
    >&2 echo "Input image $INPUT not found."
    error=1
fi
if [[ -z "$PROMPT" ]]; then
    >&2 echo "Prompt is empty."
    error=1
fi
if [[ $error -ne 0 ]]; then
    exit 1
fi


$HERE/diffuse.sh \
    --init-image "$INPUT" \
    --output "$OUTPUT" \
    --prompt "$PROMPT" \
    "$@"