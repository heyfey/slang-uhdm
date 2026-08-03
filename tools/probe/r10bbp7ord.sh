#!/bin/bash
# r10bbp7ord: dump ordered Parameters/Param_assigns for golden + ours.
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
S=$(cat /tmp/r10bbp7_slang.path)
V=${1:-ALLMOD}
/tmp/r10bbp7oq "$G" "$V" > /tmp/r10bbp7_g_$V.txt
/tmp/r10bbp7oq "$S" "$V" > /tmp/r10bbp7_s_$V.txt
wc -l /tmp/r10bbp7_g_$V.txt /tmp/r10bbp7_s_$V.txt
