#!/bin/bash
# v11u401 svaway.sh <rel work dir>: chain-keyed away census golden / pristine / verified for one sv-tests mover
H=$(cd "$(dirname "$0")" && pwd); source $H/env.sh >/dev/null; export SCX=$VB/strictcmp_x S=/tmp/v11u401_away
r=$1; P=/tmp/v11u401_wP/svtests/$r; V=/tmp/v11u401_wV/svtests/$r
g=$(grep -o 'golden cache hit [^)]*' $P/cmds.txt | awk '{print $4}')/golden.uhdm
[ -f "$g" ] || { echo "$r NOGOLDEN"; exit 0; }
echo "$r $(python3 $H/awaychain.py $g $P/slang.uhdm $V/slang.uhdm | head -1)"
