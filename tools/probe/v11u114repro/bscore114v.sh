#!/bin/bash
# score boundary movers vs golden: <list> <out>
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog; CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp; D=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
ROOT=${ROOT:-$(cd "$(dirname "$0")/.." && pwd)}; OUT=$2; mkdir -p $OUT
while read -r rel <&3; do
  key=$(echo "$rel" | sed 's#^\./##; s#/#__#g'); w=$OUT/$key; mkdir -p $w; d=$(dirname $rel); f=$(basename $rel)
  (cd $ROOT/$d && timeout 300 $SL -parse -nobuiltin -nocache -sv $f -mt 0 -mp 0 -o $w/gold </dev/null > $w/gold.log 2>&1); grc=$?
  g=$(ls $w/gold/slpp_*/*.uhdm 2>/dev/null | head -1)
  for t in pris fixv; do (cd $ROOT/$d && timeout 120 ${BINDIR:-/tmp/v11u114_bin}/$t.bin $f --single-unit --nobuiltin -o $w/$t.uhdm </dev/null >/dev/null 2>&1); echo "rc=$?" > $w/$t.rc
    if [ -n "$g" ]; then $CMP $g $w/$t.uhdm > $w/$t.cmp 2>&1; timeout 300 $D $w/$t.uhdm 2>/dev/null > $w/$t.dump; fi; done
  [ -n "$g" ] && { cp $g $w/gold.uhdm; timeout 300 $D $g 2>/dev/null > $w/gold.dump; }
  echo "$rel grc=$grc pris=$(wc -l < $w/pris.cmp 2>/dev/null)/$(cat $w/pris.rc) fixv=$(wc -l < $w/fixv.cmp 2>/dev/null)/$(cat $w/fixv.rc) $( [ -n "$g" ] && (cd $w && python3 /tmp/v11u114_dist.py . | sed 's/^\. //'))"
done 3< $1
