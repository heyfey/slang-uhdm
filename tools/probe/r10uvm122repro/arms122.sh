#!/usr/bin/env bash
# r10uvm122 — run every g122_*.sv arm under Surelog (golden), the PRISTINE and
# (optionally) the PATCHED binary, in BOTH views (def and elab), and score the
# `ref_obj -> vpiActual` cells.  MEASUREMENT ONLY; the official uhdm-cmp is the
# judge.  LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   PRI=<pristine> [PAT=<patched>] [WD=<scratch>] arms122.sh
#
# Ops traps this driver pays for:
#   * every arm is copied into its OWN subdirectory keyed on the arm's
#     RELATIVE path, so two arms may share a basename;
#   * the file list is read on fd 3 and every child gets </dev/null, so a
#     child can never eat the list;
#   * PROCESSED is asserted against LISTED — a driver that reaches nothing
#     must never read as green;
#   * every tool invocation records its own rc (a rc=139 segfault must not
#     read as "no cells").
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:-}
WD=${WD:-/tmp/r10uvm122_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls g122_*.sv | sort) > "$LIST"
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
    if [ -n "$PAT" ]; then
      ( cd "$o" && "$PAT" "$leaf" --single-unit $SUX -o pat.uhdm \
          > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    fi
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ "$tag" = pat ] && [ -z "$PAT" ] && continue
      [ -f "$f" ] || { echo "$b.$view: NO-$tag"; continue; }
      "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"
      echo "rc_dump_$tag=$?" >> "$o/rcs"
      python3 "$HERE/cells122.py" "$o/$tag.dump" > "$o/$tag.cells" 2>"$o/$tag.err"
    done
    [ -s "$o/g.cells" ] || { echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"; continue; }
    if [ -n "$PAT" ]; then
      python3 "$HERE/score122.py" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view"
    else
      python3 "$HERE/score122.py" "$o/g.cells" "$o/pris.cells" "" "$b.$view"
    fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
