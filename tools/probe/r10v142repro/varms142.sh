#!/usr/bin/env bash
# r10v142 (ADVERSARIAL VERIFIER of r10uvm142) — run every v142_*.sv arm under
# Surelog (golden), the PRISTINE and the PATCHED binary, in BOTH views, and
# score the CLASS_TYPESPEC cells with r10uvm142repro's ct142cen + score142.py.
# MEASUREMENT ONLY; the official uhdm-cmp is the sole acceptance judge.
# LHS is ALWAYS golden, RHS is ALWAYS ours.
#
#   PRI=<pristine> PAT=<patched> CEN=<ct142cen> [WD=<scratch>] varms142.sh
#
# The two numbers that decide the verdict are RIGHT->WRONG and AWAY: both must
# be 0 on every column of every arm-view.  These arms are the faces the pass's
# own grids do not carry — CLASS CONSTRUCTORS (paren-less and paren'd, in-body
# and out-of-body, package class and module class, an EXTENDED class, and the
# ESCAPED-identifier `\new` control), FORWARD-DECLARED and INTERFACE classes,
# the PROGRAM / INTERFACE / GENERATE-BLOCK homes, THREE INSTANCES of one
# module, a class-handle RETURN type, a $cast target, arrays / queues /
# dynamic / associative handle collections, and the FLAG-LEAK arm (a class
# handle reached THROUGH a struct member, where the gate's `nested0` fence is
# the only thing standing between the law and a typespec it never measured).
#
# Ops traps carried from arms142.sh: one subdirectory per arm keyed on the
# RELATIVE path, the file list on fd 3, every child </dev/null, PROCESSED
# asserted against LISTED, and EVERY rc recorded (an rc=139 segfault must not
# read as "no cells").
set -u
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PRI=${PRI:?set PRI=<pristine binary>}
PAT=${PAT:?set PAT=<patched binary>}
CEN=${CEN:?set CEN=<ct142cen binary>}
WD=${WD:-/tmp/r10v142_arms}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
SCORE=${SCORE:-$HERE/../r10uvm142repro/score142.py}
[ -f "$SCORE" ] || { echo "FATAL: no score142.py at $SCORE"; exit 3; }
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/arms.txt
(cd "$HERE" && ls v142_*.sv | sort) > "$LIST"
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
