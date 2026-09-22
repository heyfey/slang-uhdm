#!/usr/bin/env bash
# r11u101 WIDE ARM BOUNDARY (r11u98 bnd98.sh + disk hygiene: a byte-identical pair is deleted after the compare).  usage: bnd101.sh <pristine> <law> <outdir> <root...>
# Every directory under <root...> that holds at least one .sv/.v source is ONE
# arm: both binaries compile it with identical argv into the arm's own scratch
# and the two DATABASES are compared BYTE FOR BYTE.  No golden is needed to
# answer "did this patch move this arm"; an arm that moves is then measured
# against golden by hand.  Subdirectory arms are included (the sd8-12 lesson),
# the file list is read on fd 3 and every child reads /dev/null, and PROCESSED
# is asserted against LISTED.
set -u
P=${1:?pristine}; L=${2:?law}; OUT=${3:?outdir}; shift 3
mkdir -p $OUT
: > $OUT/arms.txt
shopt -s nullglob
for root in "$@"; do
  find "$root" -type d 2>/dev/null | while read -r d; do
    compgen -G "$d/*.sv" >/dev/null || compgen -G "$d/*.v" >/dev/null || continue
    echo "$d"
  done
done | sort -u > $OUT/arms.txt
LISTED=$(wc -l < $OUT/arms.txt)
n=0; moved=0; failed=0
while read -r d <&3; do
  n=$((n+1))
  w=$OUT/w$n; mkdir -p $w
  srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  ( cd "$d" && $P $srcs --single-unit --nobuiltin -o $w/pris.uhdm > $w/pris.log 2>&1 </dev/null; echo $? > $w/pris.rc )
  ( cd "$d" && $L $srcs --single-unit --nobuiltin -o $w/lawx.uhdm > $w/lawx.log 2>&1 </dev/null; echo $? > $w/lawx.rc )
  pr=$(cat $w/pris.rc); lr=$(cat $w/lawx.rc)
  if [ "$pr" != "$lr" ]; then echo "RC-DIFF $d pris=$pr law=$lr"; failed=$((failed+1)); continue; fi
  if [ ! -f $w/pris.uhdm ] || [ ! -f $w/lawx.uhdm ]; then
    [ "$pr" = 0 ] && { echo "NO-DB $d rc=$pr"; failed=$((failed+1)); }
    continue
  fi
  if cmp -s $w/pris.uhdm $w/lawx.uhdm; then rm -f $w/pris.uhdm $w/lawx.uhdm; else echo "MOVED $d"; moved=$((moved+1)); fi
done 3< $OUT/arms.txt
echo "BOUNDARY listed=$LISTED processed=$n moved=$moved rc-or-db-anomalies=$failed"
[ "$LISTED" = "$n" ] && echo "PROCESSED==LISTED" || echo "PROCESSED!=LISTED"
