#!/bin/bash
# r10bbp7ct: cmptool (per-container Compare breakdown) golden vs ours.
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
S=$(cat /tmp/r10bbp7_slang.path)
timeout 1800 /tmp/r10bbp7ct "$G" "$S" 2>&1 | head -${1:-40}
