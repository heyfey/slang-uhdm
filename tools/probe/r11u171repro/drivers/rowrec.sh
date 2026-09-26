#!/bin/bash
# rowrec.sh <row workdir (holding cmds.txt + slang.uhdm)> [max] : strict records golden (A) vs ours (B), fenced rows refused
set -u; D=$(readlink -f $1); : "${FENCED:?FENCED unset}"
for f in $FENCED; do echo "$D" | grep -qw "$f" && { echo "fenced row refused"; exit 3; }; done
G=$(grep -o 'golden cache hit [^)]*' $D/cmds.txt | awk '{print $4}'); G=$(ls $G/*.uhdm 2>/dev/null | head -1)
[ -z "$G" ] && G=$(find $D -name '*.uhdm' ! -name slang.uhdm | head -1)
$STRICT_CMP --max ${2:-20} --dump-a $D/a.rec --dump-b $D/b.rec $G $D/slang.uhdm
