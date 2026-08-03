#!/bin/bash
# r10bbp7cmp: uhdm-cmp golden vs ours for BlackBePipeInt.
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
S=$(cat /tmp/r10bbp7_slang.path)
timeout 1800 $HOME/git-repos/UHDM/build/bin/uhdm-cmp "$G" "$S" > /tmp/r10bbp7_cmp.txt 2>&1
echo "rc=$? lines=$(wc -l < /tmp/r10bbp7_cmp.txt)"
head -${1:-40} /tmp/r10bbp7_cmp.txt
