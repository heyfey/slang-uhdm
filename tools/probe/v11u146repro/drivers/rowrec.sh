#!/bin/bash
# rowrec.sh <corpus> <mode> <name> <wdA> <wdB> : golden-vs-A and golden-vs-B strict dumps, record-level comparison
c=$1; m=$2; n=$3; A=$4; B=$5; o=/tmp/v11u146_rr/$c.$m.$n; mkdir -p $o
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED (the four slang-fenced names) first"; exit 1; }
for f in $FENCED; do [ "$n" = "$f" ] && { echo "$n FENCED-SKIP"; exit; }; done
da=$(ls -d $A/$c/$m/$n-* | head -1); db=$(ls -d $B/$c/$m/$n-* | head -1)
g=$(grep -o 'golden cache hit [^)]*' $da/cmds.txt | awk '{print $4}')/golden.uhdm
timeout 900 /tmp/v11u146_bin/uhdm-strictcmp --max 3 --dump-a $o/pris.a.txt --dump-b $o/pris.b.txt $g $da/slang.uhdm > $o/pris.strict 2>&1
timeout 900 /tmp/v11u146_bin/uhdm-strictcmp --max 3 --dump-a $o/law.a.txt --dump-b $o/law.b.txt $g $db/slang.uhdm > $o/law.strict 2>&1
echo "$n/$m P:$(tail -1 $o/pris.strict) L:$(tail -1 $o/law.strict) | $(python3 /tmp/v11u146_recdiff.py $o 2 | sed "s#$o##")"
