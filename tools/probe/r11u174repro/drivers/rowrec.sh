#!/bin/bash
# rowrec.sh <rowdir> [max]: strict records of a harness row dir (golden from cmds.txt's cache line, ours slang.uhdm).
# FAIL-CLOSED on $FENCED: refuses without the four names and refuses a fenced row.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowrec.sh: export FENCED (four names) first" >&2; exit 1; }
d=$1; for f in $FENCED; do echo "$d" | grep -qw -- "$f" && { echo "rowrec.sh: fenced row refused" >&2; exit 1; }; done
g=$(grep -o 'cache hit [^)]*' $d/cmds.txt | awk '{print $3}'); [ -n "$g" ] || g=$(ls $d/*.surelog.uhdm $d/surelog*.uhdm 2>/dev/null | head -1)
gf=$(ls $g/*.uhdm 2>/dev/null | head -1); [ -f "$g" ] && gf=$g
SC=${STRICT_CMP:-/tmp/r11u174_bin/strictcmp}
$SC --max ${2:-12} --dump-a $d/A.txt --dump-b $d/B.txt $gf $d/slang.uhdm
