#!/bin/bash
# one golden: prints "<golden> C1 C2 C3 C3D rc"
g=$1
out=$(timeout 300 /home/heyfey/git-repos/UHDM/build/bin/uhdm-dump "$g" 2>/dev/null | python3 "$(dirname "$0")/cen93.py"); rc=${PIPESTATUS[0]}
echo "$g $out rc=$rc"
