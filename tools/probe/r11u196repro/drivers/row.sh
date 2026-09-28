#!/bin/bash
# r11u196: the strict records of one corpus row-mode of a workdir (sweep or rowrun), refusing the fenced names.
# usage: row.sh <workdir holding <corpus>/<mode>/<row>-*> <corpus> <row> <mode> [max=20] [extra strictcmp args]
. "$(dirname "$0")/env.sh" || exit 3
W=$1; C=$2; R=$3; M=$4; N=${5:-20}; shift 5 2>/dev/null
for f in $FENCED; do [ "$R" = "$f" ] && { echo "row.sh: fenced row refused" >&2; exit 3; }; done
d=$(ls -d $W/$C/$M/$R-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || { echo "no db"; exit 1; }
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); gu=$(find $g -name '*.uhdm' | head -1)
echo "golden=$gu ours=$d/slang.uhdm"
$SCMP --max $N "$@" $gu $d/slang.uhdm 2>&1
