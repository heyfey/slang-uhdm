#!/usr/bin/env bash
# r11v95 WIDE ARM BOUNDARY (r11u95's bnd95.sh, with the scratch REMOVED per arm
# so a 4000-arm run cannot fill /tmp — the 2026-08-24 VHDX lesson).
#   usage: bnd95v.sh <pristine> <patched> <outdir> <root...>
# Every directory under <root...> holding a .sv/.v is ONE arm; both binaries
# compile it with identical argv and the DATABASES are compared BYTE FOR BYTE.
# Subdirectory arms included; the list is read on fd 3; children read /dev/null;
# PROCESSED is asserted against LISTED.
set -u
P=${1:?pristine}; L=${2:?patched}; OUT=${3:?outdir}; shift 3
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
  w=$OUT/w; rm -rf $w; mkdir -p $w
  srcs=$(cd "$d" && ls *.sv *.v 2>/dev/null | tr '\n' ' ')
  ( cd "$d" && timeout 120 $P $srcs --single-unit --nobuiltin -o $w/pris.uhdm > $w/pris.log 2>&1 </dev/null; echo $? > $w/pris.rc )
  ( cd "$d" && timeout 120 $L $srcs --single-unit --nobuiltin -o $w/lawx.uhdm > $w/lawx.log 2>&1 </dev/null; echo $? > $w/lawx.rc )
  pr=$(cat $w/pris.rc); lr=$(cat $w/lawx.rc)
  if [ "$pr" != "$lr" ]; then echo "RC-DIFF $d pris=$pr law=$lr"; failed=$((failed+1)); continue; fi
  if [ ! -f $w/pris.uhdm ] || [ ! -f $w/lawx.uhdm ]; then
    [ "$pr" = 0 ] && { echo "NO-DB $d rc=$pr"; failed=$((failed+1)); }
    continue
  fi
  cmp -s $w/pris.uhdm $w/lawx.uhdm || { echo "MOVED $d"; moved=$((moved+1)); }
done 3< $OUT/arms.txt
rm -rf $OUT/w
echo "BOUNDARY listed=$LISTED processed=$n moved=$moved rc-or-db-anomalies=$failed"
[ "$LISTED" = "$n" ] && echo "PROCESSED==LISTED" || echo "PROCESSED!=LISTED"
