#!/bin/bash
# vsvbytes404.sh <wdA> <wdB> <out> : every sv-tests row with a slang.uhdm on both sides: normalised dump equal?
A=$1; B=$2; OUT=$3; : ${UHDM_DUMP:?}
(cd $A/svtests/work && find . -name slang.uhdm | sed 's#^\./##; s#/slang.uhdm$##' | sort) > $OUT.list
one() { r=$1; n() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's/id:[0-9]+//g; s#/tmp/v11u404_wd[A-Z]/##g' | md5sum | cut -c1-32; }
  [ -f $B/svtests/work/$r/slang.uhdm ] || { echo "$r ONLY-A"; return; }
  a=$(n $A/svtests/work/$r/slang.uhdm); b=$(n $B/svtests/work/$r/slang.uhdm); [ "$a" = "$b" ] && echo "$r same" || echo "$r MOVED"; }
export -f one; export A B UHDM_DUMP
xargs -a $OUT.list -P 3 -I{} bash -c 'one {}' > $OUT
awk '{print $2}' $OUT | sort | uniq -c
