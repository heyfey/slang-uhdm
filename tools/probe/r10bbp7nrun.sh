#!/bin/bash
# r10bbp7nrun: run the null-Rhs / line probe on golden and ours.
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
S=$(cat /tmp/r10bbp7_slang.path)
L=${1:-0}
echo "=== GOLDEN ==="
/tmp/r10bbp7nq "$G" "$L" | tail -${2:-30}
echo "=== OURS ==="
/tmp/r10bbp7nq "$S" "$L" | tail -${2:-30}
