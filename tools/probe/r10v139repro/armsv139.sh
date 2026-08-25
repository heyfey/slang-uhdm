#!/usr/bin/env bash
# r10v139 (VERIFIER) — run every v139_*.sv arm under Surelog (golden), the
# PRISTINE and the PATCHED binary in BOTH views and score with ct139cen +
# score139.py.  MEASUREMENT ONLY; uhdm-cmp stays the judge.  LHS is golden.
#   PRI=<pris> PAT=<pat> CEN=<ct139cen> [WD=<scratch>] armsv139.sh
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?}; PAT=${PAT:?}; CEN=${CEN:?}
WD=${WD:-/tmp/v139_arms}
SCORE=${SCORE:-$HERE/../r10uvm139repro/score139.py}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls v139_*.sv | sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  b=${rel%.sv}; b=${b//\//__}
  for view in def elab; do
    o=$WD/$b.$view; mkdir -p "$o"; cp "$HERE/$rel" "$o/"
    leaf=$(basename "$rel")
    if [ "$view" = elab ]; then SLX=-elabuhdm; SUX=--elabuhdm; else SLX=; SUX=; fi
    ( cd "$o" && "$SURELOG" -parse $SLX "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
    ( cd "$o" && "$PRI" "$leaf" --single-unit $SUX -o pris.uhdm > pris.log 2>&1 </dev/null ); echo "rc_pris=$?" >> "$o/rcs"
    ( cd "$o" && "$PAT" "$leaf" --single-unit $SUX -o pat.uhdm > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ -f "$f" ] || { echo "$b.$view: NO-$tag $(tr '\n' ' ' < "$o/rcs")"; continue; }
      "$CEN" "$f" > "$o/$tag.cen" 2>"$o/$tag.err" </dev/null; echo "rc_cen_$tag=$?" >> "$o/rcs"
    done
    [ -s "$o/g.cen" ] || { echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"; continue; }
    echo "== $b.$view  $(tr '\n' ' ' < "$o/rcs")"
    python3 "$SCORE" "$o/g.cen" "$o/pris.cen" "$o/pat.cen"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
