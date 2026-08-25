#!/usr/bin/env bash
# r10v127 (VERIFIER) — for each arm .sv: build Surelog golden + pristine + patched,
# and run the OFFICIAL uhdm-cmp golden-vs-ours in BOTH views.  Report rc and the
# head line count for each binary.  MEASUREMENT: the judge itself.
set -u
PRI=${PRI:?}; PAT=${PAT:?}
WD=${WD:?}
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
LIST=${LIST:?}
rm -rf "$WD"; mkdir -p "$WD"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
  [ -f "$src" ] || { echo "NOFILE $src"; continue; }
  rel=$(echo "$src" | sed 's#[^A-Za-z0-9._-]#_#g')
  for view in def elab; do
    o=$WD/$rel.$view; mkdir -p "$o"; cp "$src" "$o/"
    leaf=$(basename "$src")
    if [ "$view" = elab ]; then SLX=-elabuhdm; SUX=--elabuhdm; else SLX=; SUX=; fi
    ( cd "$o" && "$SURELOG" -parse $SLX "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 -o g > sl.log 2>&1 </dev/null ); rcs=$?
    ( cd "$o" && "$PRI" "$leaf" --single-unit $SUX -o pris.uhdm > pris.log 2>&1 </dev/null ); rcp=$?
    ( cd "$o" && "$PAT" "$leaf" --single-unit $SUX -o pat.uhdm  > pat.log  2>&1 </dev/null ); rcq=$?
    G=$o/g/slpp_all/surelog.uhdm
    if [ ! -f "$G" ] || [ ! -f "$o/pris.uhdm" ] || [ ! -f "$o/pat.uhdm" ]; then
      echo "SKIP-NOFILE $(basename $src).$view rc_sl=$rcs rc_pris=$rcp rc_pat=$rcq"; continue
    fi
    "$CMP" "$G" "$o/pris.uhdm" > "$o/pris.cmp.out" 2> "$o/pris.cmp"; rp=$?
    "$CMP" "$G" "$o/pat.uhdm"  > "$o/pat.cmp.out"  2> "$o/pat.cmp";  rq=$?
    lp=$(wc -l < "$o/pris.cmp"); lq=$(wc -l < "$o/pat.cmp")
    hp=$(grep -c '^LHS' "$o/pris.cmp"; true); hq=$(grep -c '^LHS' "$o/pat.cmp"; true)
    flag=SAME; [ "$rp" != "$rq" ] && flag=RC-CHANGED
    if [ "$rp" = "$rq" ] && [ "$lp" != "$lq" ]; then flag=DEPTH-CHANGED; fi
    if ! cmp -s "$o/pris.cmp" "$o/pat.cmp"; then [ "$flag" = SAME ] && flag=HEADTEXT-CHANGED; fi
    echo "ARM $(basename $src).$view pris_rc=$rp pris_lines=$lp pris_heads=$hp  pat_rc=$rq pat_lines=$lq pat_heads=$hq  $flag"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
