#!/usr/bin/env bash
# r10v175 VERIFIER grid — independent of the implementer's driver.
# Builds every listed arm under Surelog (GOLDEN), the PRISTINE and the PATCHED
# binary, in BOTH views; records every rc; keys scratch on the RELATIVE path;
# reads the list on fd 3 with children </dev/null; asserts PROCESSED==LISTED.
# MEASUREMENT ONLY.  LHS is ALWAYS golden.
set -u
LISTFILE=${LISTFILE:?set LISTFILE=<file of absolute arm paths>}
PRI=${PRI:?set PRI}
PAT=${PAT:?set PAT}
WD=${WD:?set WD}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
CELLS=${CELLS:-/tmp/wt_v175/tools/probe/r10uvm175repro/cells175.py}
SCORE=${SCORE:-/tmp/wt_v175/tools/probe/r10uvm175repro/score175.py}
mkdir -p "$WD"
listed=$(wc -l < "$LISTFILE"); proc=0
exec 3< "$LISTFILE"
while IFS= read -r abs <&3; do
  rel=${abs#/}
  b=${rel//\//__}; b=${b%.sv}
  for view in def elab; do
    o=$WD/$b.$view; rm -rf "$o"; mkdir -p "$o"; cp "$abs" "$o/"
    leaf=$(basename "$abs")
    if [ "$view" = elab ]; then SLX=-elabuhdm; SUX=--elabuhdm; else SLX=; SUX=; fi
    ( cd "$o" && "$SURELOG" -parse $SLX "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 \
        -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
    ( cd "$o" && "$PRI" "$leaf" --single-unit --nobuiltin $SUX -o pris.uhdm \
        > pris.log 2>&1 </dev/null ); echo "rc_pris=$?" >> "$o/rcs"
    ( cd "$o" && "$PAT" "$leaf" --single-unit --nobuiltin $SUX -o pat.uhdm \
        > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ -f "$f" ] || { echo "$b.$view: NO-$tag"; continue; }
      "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"
      echo "rc_dump_$tag=$?" >> "$o/rcs"
      sed -e "s#$o/##g" -e 's/, id:[0-9]*//g' "$o/$tag.dump" > "$o/$tag.norm"
      python3 "$CELLS" "$o/$tag.dump" > "$o/$tag.cells" 2>"$o/$tag.err"
    done
    if [ -s "$o/g.cells" ]; then
      python3 "$SCORE" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view"
      python3 "$SCORE" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view" --judge | head -1
    else
      echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"
    fi
    # raw whole-dump PRIS vs PAT (order-blind + ordered), the independent check
    if [ -f "$o/pris.norm" ] && [ -f "$o/pat.norm" ]; then
      n=$(diff "$o/pris.norm" "$o/pat.norm" | grep -c '^[<>]'; true)
      s=$(diff <(sort "$o/pris.norm") <(sort "$o/pat.norm") | grep -c '^[<>]'; true)
      echo "  RAWDIFF $b.$view ordered=$n orderblind=$s"
    fi
    for t in pris pat; do
      [ -f "$o/$t.uhdm" ] && [ -f "$o/g/slpp_all/surelog.uhdm" ] || continue
      "$CMP" "$o/g/slpp_all/surelog.uhdm" "$o/$t.uhdm" > "$o/$t.cmp" 2>&1
      echo "  JUDGE $b.$view $t rc=$? lines=$(wc -l < "$o/$t.cmp") heads=$(grep -c '^LHS:' "$o/$t.cmp"; true)"
    done
    echo "  RCS $b.$view $(tr '\n' ' ' < "$o/rcs")"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
