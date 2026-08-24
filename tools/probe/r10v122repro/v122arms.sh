#!/usr/bin/env bash
# r10v122 verifier arms driver. fd-3 list, children </dev/null, per-cell rc,
# PROCESSED asserted, arm scratch keyed on the RELATIVE path.
set -u
SRC=${SRC:?}; PRI=${PRI:?}; PAT=${PAT:?}
WD=${WD:-/tmp/v122_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
H=/tmp/v122_scratch
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$SRC" && find . -name '*.sv' | sed 's#^\./##' | sort) > "$LIST"
listed=$(wc -l < "$LIST"); proc=0
exec 3< "$LIST"
while IFS= read -r rel <&3; do
  b=${rel%.sv}; b=${b//\//__}
  for view in def elab; do
    o=$WD/$b.$view; mkdir -p "$o"; cp "$SRC/$rel" "$o/"
    leaf=$(basename "$rel")
    if [ "$view" = elab ]; then SLX=-elabuhdm; SUX=--elabuhdm; else SLX=; SUX=; fi
    ( cd "$o" && "$SURELOG" -parse $SLX "$leaf" -d uhdm -nobuiltin -mt 0 -mp 0 -o g > sl.log 2>&1 </dev/null ); echo "rc_sl=$?" >> "$o/rcs"
    ( cd "$o" && "$PRI" "$leaf" --single-unit $SUX -o pris.uhdm > pris.log 2>&1 </dev/null ); echo "rc_pris=$?" >> "$o/rcs"
    ( cd "$o" && "$PAT" "$leaf" --single-unit $SUX -o pat.uhdm > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ -f "$f" ] || { echo "$b.$view: NO-$tag $(tr '\n' ' ' < "$o/rcs")"; continue; }
      "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"; echo "rc_dump_$tag=$?" >> "$o/rcs"
      python3 "$H/v122cells.py" "$o/$tag.dump" > "$o/$tag.cells" 2>"$o/$tag.err"
    done
    [ -s "$o/g.cells" ] || { echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"; continue; }
    echo "--- rcs: $(tr '\n' ' ' < "$o/rcs")"
    python3 "$H/v122score.py" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view"
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
