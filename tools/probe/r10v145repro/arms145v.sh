#!/usr/bin/env bash
# r10v145 (VERIFIER) -- run every v145_*.sv arm under Surelog (golden), the
# PRISTINE and the PATCHED binary, in BOTH views, score with ct145cen +
# score145.py, AND run the official uhdm-cmp golden-vs-ours on each side.
# MEASUREMENT ONLY; uhdm-cmp is the judge.  LHS is ALWAYS golden.
#   PRI=<pristine> PAT=<patched> CEN=<ct145cen> [WD=<scratch>] arms145v.sh
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?set PRI}
PAT=${PAT:?set PAT}
CEN=${CEN:?set CEN}
SCORE=${SCORE:?set SCORE=<score145.py>}
WD=${WD:-/tmp/v145_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${CMP:-$HOME/.local/bin/uhdm-cmp}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls v145_*.sv | sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  b=${rel%.sv}; b=${b//\//__}
  for view in def elab; do
    o=$WD/$b.$view; mkdir -p "$o"; cp "$HERE/$rel" "$o/"
    leaf=$(basename "$rel")
    if [ "$view" = elab ]; then SLX=-elabuhdm; SUX=--elabuhdm; else SLX=; SUX=; fi
    ( cd "$o" && "$SURELOG" -parse $SLX "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 \
        -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
    ( cd "$o" && "$PRI" "$leaf" --single-unit $SUX -o pris.uhdm \
        > pris.log 2>&1 </dev/null ); echo "rc_pris=$?" >> "$o/rcs"
    ( cd "$o" && "$PAT" "$leaf" --single-unit $SUX -o pat.uhdm \
        > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ -f "$f" ] || { echo "$b.$view: NO-$tag $(tr '\n' ' ' < "$o/rcs")"; continue; }
      "$CEN" "$f" > "$o/$tag.cen" 2>"$o/$tag.err" </dev/null
      echo "rc_cen_$tag=$?" >> "$o/rcs"
    done
    echo "== $b.$view  $(tr '\n' ' ' < "$o/rcs")"
    G=$o/g/slpp_all/surelog.uhdm
    if [ -f "$G" ]; then
      for tag in pris pat; do
        if [ -f "$o/$tag.uhdm" ]; then
          "$CMP" "$G" "$o/$tag.uhdm" > "$o/cmp_$tag.out" 2> "$o/cmp_$tag.err" </dev/null
          echo "   CMP_$tag rc=$? lines=$(wc -l < "$o/cmp_$tag.err") heads=$(grep -c '^LHS:' "$o/cmp_$tag.err" || true)"
        fi
      done
    fi
    if [ -s "$o/g.cen" ] && [ -s "$o/pris.cen" ] && [ -s "$o/pat.cen" ]; then
      python3 "$SCORE" "$o/g.cen" "$o/pris.cen" "$o/pat.cen"
    else
      echo "   (census not scoreable: missing cells)"
    fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
