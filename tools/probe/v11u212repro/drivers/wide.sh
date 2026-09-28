#!/bin/bash
# wide.sh <casedir> : both views, law vs fix1 bytes + fix1 trace (R11U212_TRACE); fenced refused
. $(dirname "$0")/env.sh || exit 3
c=$1; for n in $FENCED; do echo "$c" | grep -qw "$n" && exit 0; done
SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args); [ ! -f $c/args ] && [ -f $c/files ] && SRC=$(cat $c/files | tr "\n" " ")
SV=-sv; [ "$SRC" = dut.v ] && SV=
w=/tmp/v11u212_wide/$(echo $c | tr '/' '_'); mkdir -p $w/tr
for el in 0 1; do ox=""; [ $el = 1 ] && ox=--elabuhdm
 rm -f $w/l$el.uhdm $w/f$el.uhdm
 (cd $c && timeout 300 $B/law.bin $SRC --single-unit --nobuiltin $ox -o $w/l$el.uhdm >/dev/null 2>&1)
 (cd $c && R11U212_TRACE=$w/tr timeout 300 $B/fix1.bin $SRC --single-unit --nobuiltin $ox -o $w/f$el.uhdm >/dev/null 2>&1)
 m=SAME; [ -s $w/l$el.uhdm ] || m=NOOUT; [ "$m" = SAME ] && ! cmp -s $w/l$el.uhdm $w/f$el.uhdm && m=MOVED
 echo "$c el=$el $m owner=$(cat $w/tr/* 2>/dev/null | grep -c OwnerDef)"
 rm -f $w/tr/*
done
