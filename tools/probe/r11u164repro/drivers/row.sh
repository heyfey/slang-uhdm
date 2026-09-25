#!/bin/bash
# row.sh <row workdir (…/<mode>/<test>-<hash>)> [MAX]: uhdm-strictcmp of the row's cached golden against its
# slang.uhdm, record dumps beside it (strict.a.txt / strict.b.txt).  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "row.sh: source drivers/env.sh" >&2; exit 2; }
d=$1; n=$(basename $d); n=${n%-*}
for f in $FENCED; do [ "$f" = "$n" ] && { echo "$d fenced, skipped"; exit 0; }; done
g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')
gu=$(find $g -name '*.uhdm' | head -1)
$STRICT_CMP --max ${2:-20} --dump-a $d/strict.a.txt --dump-b $d/strict.b.txt $gu $d/slang.uhdm > $d/strict.txt 2>&1
cat $d/strict.txt
