#!/bin/bash
# rowtoward.sh <corpus> <mode> <row> <pristine corpus root> <law corpus root> [n]: the toward.py reading of one corpus row-mode.
# FAIL-CLOSED on $FENCED: refuses without the four names and refuses a fenced row.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "rowtoward.sh: export FENCED first" >&2; exit 1; }
for f in $FENCED; do [ "$3" = "$f" ] && { echo "fenced row refused" >&2; exit 1; }; done
D=$(cd $(dirname $0) && pwd); SC=${STRICT_CMP:-/tmp/r11u174_bin/strictcmp}
p=$(ls -d $4/$2/$3-* | head -1); l=$(ls -d $5/$2/$3-* | head -1)
g=$(grep -o 'cache hit [^)]*' $p/cmds.txt | awk '{print $3}')/golden.uhdm
T=/tmp/r11u174_tw/$1_$2_$3; mkdir -p $T
$SC --dump-a $T/A.txt --dump-b $T/P.txt $g $p/slang.uhdm > $T/P.strict 2>&1
$SC --dump-a $T/A.txt --dump-b $T/L.txt $g $l/slang.uhdm > $T/L.strict 2>&1
echo "$1 $2 $3: $(tail -1 $T/P.strict) -> $(tail -1 $T/L.strict); $(python3 $D/toward.py $T/A.txt $T/P.txt $T/L.txt ${6:-0})"
