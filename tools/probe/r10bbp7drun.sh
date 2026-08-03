#!/bin/bash
# r10bbp7drun: dump the CMP-relevant param_assign projection for golden+ours
# and diff.  Usage: r10bbp7drun.sh [view-substring]
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
S=$(cat /tmp/r10bbp7_slang.path)
V=${1:-}
/tmp/r10bbp7dq "$G" "$V" > /tmp/r10bbp7_gd.txt
/tmp/r10bbp7dq "$S" "$V" > /tmp/r10bbp7_sd.txt
wc -l /tmp/r10bbp7_gd.txt /tmp/r10bbp7_sd.txt
echo "== diff count: $(diff /tmp/r10bbp7_gd.txt /tmp/r10bbp7_sd.txt | grep -c '^[<>]')"
diff /tmp/r10bbp7_gd.txt /tmp/r10bbp7_sd.txt | head -${2:-30}
