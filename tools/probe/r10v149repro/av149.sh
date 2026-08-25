#!/bin/bash
# v149 VERIFIER grid driver -- BOTH VIEWS (def + elab), golden/pristine/patched.
# fd-3 file list, children </dev/null, PROCESSED asserted, scratch keyed on the
# RELATIVE path, every rc recorded, binaries printed.
set -u
SRCDIR=${SRCDIR:?}; WD=${WD:?}; PRIS=${PRIS:?}; PAT=${PAT:?}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CEN=${CT149CEN:?}
echo "BINARIES pris=$PRIS pat=$PAT surelog=$SURELOG cmp=$CMP cen=$CEN"
mkdir -p "$WD"; : > "$WD/ARMS.txt"
listed=0; processed=0
while read -r -u 3 f; do
  listed=$((listed+1))
  rel=${f#"$SRCDIR"/}; key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}
  o="$WD/$key"; mkdir -p "$o"
  ( cd "$SRCDIR" && "$SURELOG" -parse -sv "$rel" -mt 0 -mp 0 -o "$o/sld" ) </dev/null >"$o/sld.log" 2>&1; gdrc=$?
  ( cd "$SRCDIR" && "$SURELOG" -parse -sv "$rel" -elabuhdm -mt 0 -mp 0 -o "$o/sle" ) </dev/null >"$o/sle.log" 2>&1; gerc=$?
  ( cd "$SRCDIR" && "$PRIS" "$rel" --single-unit -o "$o/prisd.uhdm" ) </dev/null >"$o/prisd.log" 2>&1; pdrc=$?
  ( cd "$SRCDIR" && "$PAT"  "$rel" --single-unit -o "$o/patd.uhdm"  ) </dev/null >"$o/patd.log"  2>&1; qdrc=$?
  ( cd "$SRCDIR" && "$PRIS" "$rel" --single-unit --elabuhdm -o "$o/prise.uhdm" ) </dev/null >"$o/prise.log" 2>&1; perc=$?
  ( cd "$SRCDIR" && "$PAT"  "$rel" --single-unit --elabuhdm -o "$o/pate.uhdm"  ) </dev/null >"$o/pate.log"  2>&1; qerc=$?
  GD="$o/sld/slpp_all/surelog.uhdm"; [ -f "$GD" ] || GD="$o/sld/surelog.uhdm"
  GE="$o/sle/slpp_all/surelog.uhdm"; [ -f "$GE" ] || GE="$o/sle/surelog.uhdm"
  line="$rel  rc g=$gdrc/$gerc p=$pdrc/$perc q=$qdrc/$qerc"
  for v in d e; do
    [ $v = d ] && { G=$GD; P="$o/prisd.uhdm"; Q="$o/patd.uhdm"; } || { G=$GE; P="$o/prise.uhdm"; Q="$o/pate.uhdm"; }
    pl=-; ql=-; ph=-; qh=-
    if [ -f "$G" ] && [ -f "$P" ]; then "$CMP" "$G" "$P" > "$o/pris.$v.cmp" 2>&1; pl=$(wc -l < "$o/pris.$v.cmp"); ph=$(grep -c '^LHS:' "$o/pris.$v.cmp"; true); fi
    if [ -f "$G" ] && [ -f "$Q" ]; then "$CMP" "$G" "$Q" > "$o/pat.$v.cmp" 2>&1;  ql=$(wc -l < "$o/pat.$v.cmp");  qh=$(grep -c '^LHS:' "$o/pat.$v.cmp"; true); fi
    bid=differ; { [ -f "$P" ] && [ -f "$Q" ] && cmp -s "$P" "$Q"; } && bid=BYTE-IDENTICAL
    line="$line | $v: cmp pris=$pl($ph) pat=$ql($qh) ours=$bid"
    for tag in sl:$G pris:$P pat:$Q; do
      n=${tag%%:*}; db=${tag#*:}
      if [ -f "$db" ]; then "$CEN" "$db" "$n.$key.$v" > "$o/cen.$n.$v.txt" 2>&1; else : > "$o/cen.$n.$v.txt"; fi
    done
  done
  echo "$line" | tee -a "$WD/ARMS.txt"
  processed=$((processed+1))
done 3< <(find "$SRCDIR" -name '*.sv' | sort)
echo "LISTED=$listed PROCESSED=$processed"
[ "$listed" -eq "$processed" ] && [ "$listed" -gt 0 ] && echo "ARM-DRIVER OK" || echo "ARM-DRIVER FAIL"
