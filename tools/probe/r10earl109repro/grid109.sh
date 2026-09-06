#!/usr/bin/env bash
# r10earl109 GRID DRIVER -- MEASUREMENT ONLY.  The official uhdm-cmp is the sole
# acceptance judge; this prints its line/head counts and the cen109 census
# beside them.
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> bash grid109.sh <outdir> [arm.sv ...]
# GUARDS (each an ops trap this campaign has paid for):
#   * every producer's rc is RECORDED and printed; a missing database prints
#     REJECT and is COUNTED, never silently skipped;
#   * children get </dev/null so no child can eat the arm list;
#   * the -top is read from TOPS.txt, keyed on the arm basename;
#   * the census rc is asserted (CENRC), so a census that restored nothing
#     cannot read as "no rows differ".
set -u
PAT=${PATCHED_BIN:?set PATCHED_BIN}; PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
CEN=${CEN_BIN:-/tmp/r10earl109_cen109}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
HERE=$(cd "$(dirname "$0")" && pwd)
ARMD=${ARM_DIR:-$HERE}
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
FILES=("$@"); [ ${#FILES[@]} -eq 0 ] && FILES=("$ARMD"/g?_*109.sv)
printf '%-16s %-6s %5s %5s %5s %10s %10s\n' ARM VIEW SLRC PRC ARC "PRIS c/h" "PATCH c/h"
for f0 in "${FILES[@]}"; do
  f=$f0; case "$f" in /*) ;; *) f="$ARMD/$f0";; esac
  [ -f "$f" ] || { echo "MISSING $f0"; continue; }
  arm=$(basename "$f" .sv)
  t=$(awk -v a="$arm" '$1==a{print $2}' "$ARMD/TOPS.txt" | head -1)
  T=""; U=""; [ -n "$t" ] && { T="-top $t"; U="--top $t"; }
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
    ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl $T "$f" > sl.log 2>&1 </dev/null ); slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$PRIS" $SUF $U "$f" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && "$PAT"  $SUF $U "$f" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
      printf '%-16s %-6s %5s %5s %5s %10s %10s  REJECT\n' "$arm" "$view" "$slrc" "$prc" "$arc" - -
      continue
    fi
    "$CMP" "$G" "$d/pris.uhdm"    > "$d/pris.cmp" 2>&1
    "$CMP" "$G" "$d/patched.uhdm" > "$d/patch.cmp" 2>&1
    pc=$(wc -l < "$d/pris.cmp");  ph=$(grep -c '^LHS:' "$d/pris.cmp"; true)
    ac=$(wc -l < "$d/patch.cmp"); ah=$(grep -c '^LHS:' "$d/patch.cmp"; true)
    printf '%-16s %-6s %5s %5s %5s %10s %10s\n' "$arm" "$view" "$slrc" "$prc" "$arc" "$pc/$ph" "$ac/$ah"
    "$CEN" "$G"              "${arm}_${view}" > "$d/cen.gold.txt"  2>&1
    "$CEN" "$d/pris.uhdm"    "${arm}_${view}" > "$d/cen.pris.txt"  2>&1
    "$CEN" "$d/patched.uhdm" "${arm}_${view}" > "$d/cen.patch.txt" 2>&1
    for c in gold pris patch; do
      r=$(sed -n 's/^CENRC //p' "$d/cen.$c.txt")
      [ "$r" = "0" ] || echo "  CENRC-BAD $arm $view $c rc=${r:-none}"
    done
  done
done
