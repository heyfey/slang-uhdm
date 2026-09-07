#!/usr/bin/env bash
# r10vearl117 ADVERSARIAL GRID DRIVER -- MEASUREMENT ONLY.
#
# For each arm and each view (plain / elab) it builds THREE databases (golden,
# ours-pristine, ours-patched), runs the official uhdm-cmp on both of ours, and
# ALSO takes a path-normalised WHOLE-DUMP diff between the two of ours, so a
# regression OUTSIDE the sig117 select-bound family cannot hide.
#
#   PRISTINE_BIN=<bin> PATCHED_BIN=<bin> SIG_BIN=<sig117> ARM_DIR=<dir> \
#     bash vgrid117.sh <outdir> [arm.sv ...]
#
# GUARDS: every producer's rc is RECORDED; children get </dev/null; the arm
# file list is read from the command line or the arm dir; -top is the arm's
# basename; a missing database prints REJECT and is COUNTED; sig117's own
# CENRC accounting line is asserted on all three sides.
set -u
PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
PAT=${PATCHED_BIN:?set PATCHED_BIN}
SIG=${SIG_BIN:?set SIG_BIN}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
ARMD=${ARM_DIR:?set ARM_DIR}
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
FILES=("$@"); [ ${#FILES[@]} -eq 0 ] && FILES=("$ARMD"/va*.sv)
printf '%-18s %-6s %5s %5s %5s %10s %10s %10s\n' ARM VIEW SLRC PRC ARC "PRIS c/h" "PATCH c/h" DUMPDIFF
for f0 in "${FILES[@]}"; do
  f=$f0; case "$f" in /*) ;; *) f="$ARMD/$f0";; esac
  [ -f "$f" ] || { echo "MISSING $f0"; continue; }
  arm=$(basename "$f" .sv)
  for view in plain elab; do
    case $view in
      plain) SLF="-parse";           SUF="";;
      elab)  SLF="-parse -elabuhdm"; SUF="--elabuhdm";;
    esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
    ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl -top "$arm" "$f" > sl.log 2>&1 </dev/null ); slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$PRIS" $SUF --top "$arm" "$f" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && "$PAT"  $SUF --top "$arm" "$f" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
      printf '%-18s %-6s %5s %5s %5s %10s %10s %10s  REJECT\n' "$arm" "$view" "$slrc" "$prc" "$arc" - - -
      continue
    fi
    "$CMP" "$G" "$d/pris.uhdm"    > "$d/pris.cmp" 2>&1
    "$CMP" "$G" "$d/patched.uhdm" > "$d/patch.cmp" 2>&1
    pc=$(wc -l < "$d/pris.cmp");  ph=$(grep -c '^LHS:' "$d/pris.cmp"; true)
    ac=$(wc -l < "$d/patch.cmp"); ah=$(grep -c '^LHS:' "$d/patch.cmp"; true)
    "$DUMP" "$d/pris.uhdm"    2>/dev/null | sed "s#$d/##g; s#$OUT/##g" > "$d/pris.dump"
    "$DUMP" "$d/patched.uhdm" 2>/dev/null | sed "s#$d/##g; s#$OUT/##g" > "$d/patch.dump"
    dd=$(diff "$d/pris.dump" "$d/patch.dump" | grep -c '^[<>]'; true)
    printf '%-18s %-6s %5s %5s %5s %10s %10s %10s\n' "$arm" "$view" "$slrc" "$prc" "$arc" "$pc/$ph" "$ac/$ah" "$dd"
    "$SIG" "$G"              "${arm}_${view}" > "$d/sig.gold.txt"  2>&1
    "$SIG" "$d/pris.uhdm"    "${arm}_${view}" > "$d/sig.pris.txt"  2>&1
    "$SIG" "$d/patched.uhdm" "${arm}_${view}" > "$d/sig.patch.txt" 2>&1
    for c in gold pris patch; do
      r=$(sed -n 's/^CENRC //p' "$d/sig.$c.txt")
      [ "$r" = "0" ] || echo "  CENRC-BAD $arm $view $c rc=${r:-none}"
    done
  done
done
