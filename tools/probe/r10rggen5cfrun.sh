#!/bin/bash
# r10rggen5cfrun: run the constant locator on both sides.
#   r10rggen5cfrun.sh <line> <col>
G=$HOME/.cache/slang-uhdm-goldens/6fc99d8f4119ff55b3e1/golden.uhdm
S=$(cat /tmp/r10rggen5_slang.path)
echo "== GOLDEN"
/tmp/r10rggen5_cf "$G" "$1" "$2"
echo "== OURS"
/tmp/r10rggen5_cf "$S" "$1" "$2"
