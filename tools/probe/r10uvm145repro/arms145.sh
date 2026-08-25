#!/usr/bin/env bash
# r10uvm145 — run every g145_*.sv arm under Surelog (golden), the PRISTINE and
# (optionally) the PATCHED binary, in BOTH views (def and elab), and score the
# BODY / STMT / LOC cells with ct145cen + score145.py.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
# LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   PRI=<pristine> [PAT=<patched>] CEN=<ct145cen> [WD=<scratch>] arms145.sh
#
# Ops traps this driver pays for (carried from r10uvm142repro/arms142.sh):
#   * every arm is copied into its OWN subdirectory keyed on the arm's
#     RELATIVE path, so two arms may share a basename;
#   * the file list is read on fd 3 and every child gets </dev/null;
#   * PROCESSED is asserted against LISTED;
#   * every tool invocation records its own rc (an rc=139 segfault must not
#     read as "no cells").
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:-}
CEN=${CEN:?set CEN=<ct145cen binary>}
WD=${WD:-/tmp/r10uvm145_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls g145_*.sv | sort) > "$LIST"
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
      [ -f "$f" ] || { echo "$b.$view: NO-$tag $(tr '\n' ' ' < "$o/rcs")"; continue; }
      "$CEN" "$f" > "$o/$tag.cen" 2>"$o/$tag.err" </dev/null
      echo "rc_cen_$tag=$?" >> "$o/rcs"
    done
    [ -s "$o/g.cen" ] || { echo "$b.$view: NO-GOLDEN-CELLS $(tr '\n' ' ' < "$o/rcs")"; continue; }
    echo "== $b.$view  $(tr '\n' ' ' < "$o/rcs")"
    if [ -n "$PAT" ]; then
      python3 "$HERE/score145.py" "$o/g.cen" "$o/pris.cen" "$o/pat.cen"
    else
      echo "   (pristine as both sides: golden-vs-pristine calibration)"
      python3 "$HERE/score145.py" "$o/g.cen" "$o/pris.cen" "$o/pris.cen"
    fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK
