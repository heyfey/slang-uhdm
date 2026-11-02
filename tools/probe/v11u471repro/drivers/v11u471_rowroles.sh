#!/bin/bash
# rerun one sv-tests row's recorded slang command with pristine; rolecmp golden vs pristine and vs law
R=$1; W=/tmp/v11u471_sw/svtests/work/$R
G=$W/slpp_all/surelog.uhdm; [ -f "$G" ] || G=$(sed -n "s/^surelog: (golden cache hit \(.*\))/\1/p" $W/cmds.txt)/golden.uhdm
[ -f "$G" ] || { echo "$R no golden"; exit; }
cmd=$(sed -n 's/^slang: *//p' $W/cmds.txt)
O=/tmp/v11u471_rowp/$(echo $R | tr / _).uhdm; mkdir -p /tmp/v11u471_rowp; rm -f $O
args=$(echo "$cmd" | cut -d' ' -f2- | sed "s#-o [^ ]*slang.uhdm#-o $O#")
(cd /tmp/v11u471_rowp && /tmp/v11u471_bin/pristine $args > /dev/null 2>&1); rc=$?
echo "$R rc=$rc pris: $(/tmp/v11u471_tools/rolecmp $G $O) | law: $(/tmp/v11u471_tools/rolecmp $G $W/slang.uhdm) | strict pris-vs-law: $(/tmp/v11u471_bin/uhdm-strictcmp $O $W/slang.uhdm 2>&1 | tail -1)"
if [ ! -f $W/slang.uhdm ]; then L=${O%.uhdm}.law.uhdm; rm -f $L; args2=$(echo "$cmd" | cut -d' ' -f2- | sed "s#-o [^ ]*slang.uhdm#-o $L#"); (cd /tmp/v11u471_rowp && /tmp/v11u471_bin/law $args2 > /dev/null 2>&1); echo "  rerun law rc=$?: $(/tmp/v11u471_tools/rolecmp $G $L) | strict golden-vs-law: $(/tmp/v11u471_bin/uhdm-strictcmp $G $L 2>&1 | tail -1) | strict golden-vs-pris: $(/tmp/v11u471_bin/uhdm-strictcmp $G $O 2>&1 | tail -1)"; fi
