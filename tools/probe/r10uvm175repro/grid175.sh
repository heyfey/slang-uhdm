#!/usr/bin/env bash
# r10uvm175 — build every g175_*.sv arm under Surelog (GOLDEN), the PRISTINE
# and (optionally) the PATCHED binary, in BOTH views, and score the hier_path
# ELEMENT-SHAPE VECTORS.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   PRI=<pristine> [PAT=<patched>] [WD=<scratch>] grid175.sh
#
# Ops traps this driver pays for (RESUME.md §9 "Boundary gates"):
#   * every arm is copied into its OWN subdirectory keyed on the arm's
#     RELATIVE path, so two arms may share a basename;
#   * the file list is read on fd 3 and every child gets </dev/null, so a
#     child can never eat the list;
#   * PROCESSED is asserted against LISTED — a driver that reaches nothing
#     must never read as green;
#   * every tool invocation records its own rc (an rc=139 segfault must not
#     read as "no cells");
#   * the DEF and ELAB listings are kept in SEPARATE files and never merged.
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:-}
WD=${WD:-/tmp/r10uvm175_grid}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls g175_*.sv | sort) > "$LIST"
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
    ( cd "$o" && "$PRI" "$leaf" --single-unit --nobuiltin $SUX -o pris.uhdm \
        > pris.log 2>&1 </dev/null ); echo "rc_pris=$?" >> "$o/rcs"
    if [ -n "$PAT" ]; then
      ( cd "$o" && "$PAT" "$leaf" --single-unit --nobuiltin $SUX -o pat.uhdm \
          > pat.log 2>&1 </dev/null ); echo "rc_pat=$?" >> "$o/rcs"
    fi
    for w in g:g/slpp_all/surelog.uhdm pris:pris.uhdm pat:pat.uhdm; do
      tag=${w%%:*}; f=$o/${w#*:}
      [ "$tag" = pat ] && [ -z "$PAT" ] && continue
      [ -f "$f" ] || { echo "$b.$view: NO-$tag"; continue; }
      "$DUMP" "$f" 2>/dev/null </dev/null > "$o/$tag.dump"
      echo "rc_dump_$tag=$?" >> "$o/rcs"
      python3 "$HERE/cells175.py" "$o/$tag.dump" > "$o/$tag.cells" 2>"$o/$tag.err"
    done
    if [ -s "$o/g.cells" ]; then
      if [ -n "$PAT" ]; then
        python3 "$HERE/score175.py" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view"
        python3 "$HERE/score175.py" "$o/g.cells" "$o/pris.cells" "$o/pat.cells" "$b.$view" --judge | head -1
      else
        python3 "$HERE/score175.py" "$o/g.cells" "$o/pris.cells" "" "$b.$view"
        python3 "$HERE/score175.py" "$o/g.cells" "$o/pris.cells" "" "$b.$view" --judge | head -1
      fi
    else
      echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"
    fi
    # the OFFICIAL judge on the same arm, both binaries
    for t in pris pat; do
      [ "$t" = pat ] && [ -z "$PAT" ] && continue
      [ -f "$o/$t.uhdm" ] && [ -f "$o/g/slpp_all/surelog.uhdm" ] || continue
      "$CMP" "$o/g/slpp_all/surelog.uhdm" "$o/$t.uhdm" > "$o/$t.cmp" 2>&1
      echo "  JUDGE $b.$view $t rc=$? lines=$(wc -l < "$o/$t.cmp") heads=$(grep -c '^LHS:' "$o/$t.cmp"; true)"
    done
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
