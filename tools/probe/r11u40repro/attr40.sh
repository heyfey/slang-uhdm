#!/bin/bash
# r11u40 — ORDER-BLIND attribution of a byte mover.
#   usage: attr.sh <name> <mode> <workdirA> <workdirB>
# Dumps both databases, strips the banner, NORMALISES the embedded workdir
# paths (a dump path embeds the workdir), SORTS, and diffs.  Zero lines means
# the two databases are the SAME CONTENT in a different order — the coin, not
# a law.  Non-zero lines are the law's, and are printed.
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
n=${1:?}; m=${2:?}; A=${3:?}; B=${4:?}
da=$(find $A/$m -maxdepth 1 -type d -name "$n-*" | head -1)
db=$(find $B/$m -maxdepth 1 -type d -name "$n-*" | head -1)
[ -z "$da" ] || [ -z "$db" ] && { echo "$n/$m NOT_FOUND"; exit 3; }
$DUMP $da/slang.uhdm 2>&1 | tail -n +2 | sed "s#$A##g;s#$B##g" | sort > /tmp/r11u40_attr.a
$DUMP $db/slang.uhdm 2>&1 | tail -n +2 | sed "s#$A##g;s#$B##g" | sort > /tmp/r11u40_attr.b
o=$(diff /tmp/r11u40_attr.a /tmp/r11u40_attr.b | grep -c '^[<>]'; true)
u=$(diff <($DUMP $da/slang.uhdm 2>&1 | tail -n +2 | sed "s#$A##g;s#$B##g") \
         <($DUMP $db/slang.uhdm 2>&1 | tail -n +2 | sed "s#$A##g;s#$B##g") | grep -c '^[<>]'; true)
echo "$n [$m] order-blind-difflines=$o in-order-difflines=$u"
[ "$o" != "0" ] && diff /tmp/r11u40_attr.a /tmp/r11u40_attr.b | grep '^[<>]' | head -20
exit 0
