#!/bin/bash
# toward <corpus/mode/rowdir> <P-root> <L-root> : strict record multiset toward golden
source $(dirname $0)/env.sh
r=$1; P=$2; L=$3
for f in $FENCED; do grep -qw "$f" <<<"$r" && { echo "fenced refused"; exit 9; }; done
g=$(grep -o 'golden cache hit [^)]*' /tmp/v11u174_swL/$r/cmds.txt | awk '{print $4}'); G=$(ls $g/*.uhdm | head -1)
s=/tmp/v11u174_tw; mkdir -p $s; k=$(echo $r | tr / _)
$STRICT_CMP --dump-a $s/$k.a --dump-b $s/$k.bP $G $P/$r/slang.uhdm > $s/$k.sP 2>&1
$STRICT_CMP --dump-a $s/$k.a --dump-b $s/$k.bL $G $L/$r/slang.uhdm > $s/$k.sL 2>&1
echo "$r P=$(tail -n1 $s/$k.sP | tr ' ' _) L=$(tail -n1 $s/$k.sL | tr ' ' _) $(python3 /tmp/wt_v11u174/tools/probe/r11u174repro/drivers/toward.py $s/$k.a $s/$k.bP $s/$k.bL 3)"
