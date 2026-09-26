#!/bin/bash
# rowrec.sh <sweep workdir> <corpus> <mode> <row> [max] : strict records golden (A) vs ours (B) of one sweep row, fenced rows refused
set -u; : "${FENCED:?FENCED unset}"; W=$1 C=$2 M=$3 R=$4
for f in $FENCED; do [ "$R" = "$f" ] && { echo "fenced row refused"; exit 3; }; done
D=$(ls -d $W/$C/$M/$R-* 2>/dev/null | head -1); [ -z "$D" ] && { echo "no dir"; exit 1; }
G=$(grep -o 'golden cache hit [^)]*' $D/cmds.txt | awk '{print $4}'); G=$(ls $G/*.uhdm 2>/dev/null | head -1)
[ -z "$G" ] && G=$(find $D -name '*.uhdm' ! -name slang.uhdm | head -1)
$STRICT_CMP --max ${5:-20} --dump-a $D/a.rec --dump-b $D/b.rec $G $D/slang.uhdm
