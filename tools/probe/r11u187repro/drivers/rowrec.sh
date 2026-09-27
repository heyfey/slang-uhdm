#!/bin/bash
# rowrec.sh <corpus> <mode> <test> <swA> <swB> [max]: the strict records of one row-mode in two sweeps (golden from the
# cache entry cmds.txt names), and their record movement (recmv.py).  Refuses a fenced test (word boundary).
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
co=$1; mo=$2; te=$3; a=$4; b=$5; mx=${6:-2000}
if echo "$te" | grep -qP "$FENCED_RE"; then echo "FENCE refuse"; exit 4; fi
da=$(ls -d $a/$co/$mo/$te-* | head -1); db=$(ls -d $b/$co/$mo/$te-* | head -1)
g=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' $da/cmds.txt)/golden.uhdm
o=/tmp/r11u187_rows/$co.$mo.$te; mkdir -p $o
$STRICT_CMP --max $mx $g $da/slang.uhdm > $o/A.strict 2>&1
$STRICT_CMP --max $mx $g $db/slang.uhdm > $o/B.strict 2>&1
echo "$co $mo $te: A $(tail -1 $o/A.strict) | B $(tail -1 $o/B.strict)"
python3 $(dirname "${BASH_SOURCE[0]}")/recmv.py $o/A.strict $o/B.strict
