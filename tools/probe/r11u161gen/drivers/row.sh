#!/bin/bash
# row.sh <sweepdir> <corpus> <mode> <test> [max]: strict records of one row of a sweep workdir
# (<sweepdir>/<corpus>/<mode>/<test>-<hash>/slang.uhdm vs the golden cache entry its cmds.txt names).
# Writes /tmp/r11u161_rows/<tag>/<corpus>_<mode>_<test>.{strict,ra,rb}.  Fail-closed on $FENCED.
[ -n "$FENCED" ] || { echo "row.sh: source drivers/env.sh" >&2; exit 2; }
sw=$1; co=$2; mo=$3; t=$4; mx=${5:-50}
echo "$t" | grep -qwE "$(echo $FENCED | tr ' ' '|')" && { echo "row.sh: fenced row refused" >&2; exit 2; }
d=$(ls -d $sw/$co/$mo/$t-* 2>/dev/null | grep -E "/$t-[0-9a-f]{8}$" | head -1)
[ -n "$d" ] || { echo "$co $mo $t NO_DIR"; exit 0; }
gc=$(grep -o 'golden cache [a-z]* *[^ )]*' $d/cmds.txt | awk '{print $NF}')
g=$gc/golden.uhdm; [ -s "$g" ] || g=$(ls $gc/*.uhdm 2>/dev/null | head -1)
o=/tmp/r11u161_rows/$(basename $sw); mkdir -p $o
f=$o/${co}_${mo}_$t
$STRICT_CMP --max $mx --dump-a $f.ra --dump-b $f.rb $g $d/slang.uhdm > $f.strict 2>&1
echo "$co $mo $t $(tail -1 $f.strict)"
