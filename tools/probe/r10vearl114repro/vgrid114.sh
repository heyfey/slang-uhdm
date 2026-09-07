#!/usr/bin/env bash
# r10vearl114 ARM DRIVER -- MEASUREMENT ONLY.  The official uhdm-cmp is the
# sole acceptance judge; this prints its line/head counts plus the RAW vts114
# rows for golden / pristine / patched so a three-way diff IS the finding.
# Guards: every producer rc is RECORDED and printed; children get </dev/null;
# a missing database prints REJECT and is COUNTED; the reader's rc is asserted.
#   PATCHED_BIN=.. PRISTINE_BIN=.. bash vgrid114.sh <outdir> [arm.sv ...]
set -u
PAT=${PATCHED_BIN:?set PATCHED_BIN}; PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
HERE=$(cd "$(dirname "$0")" && pwd)
VTS=${VTS_BIN:-$HERE/vts114}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
ARMD=${ARM_DIR:-$HERE}
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
FILES=("$@"); [ ${#FILES[@]} -eq 0 ] && FILES=("$ARMD"/v?_*114.sv)
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
    "$VTS" "$G"              "G" > "$d/vts.gold.txt"  2>&1
    "$VTS" "$d/pris.uhdm"    "P" > "$d/vts.pris.txt"  2>&1
    "$VTS" "$d/patched.uhdm" "Q" > "$d/vts.patch.txt" 2>&1
    for c in gold pris patch; do
      r=$(sed -n 's/^VTSRC //p' "$d/vts.$c.txt")
      [ "$r" = "0" ] || echo "  VTSRC-BAD $arm $view $c rc=${r:-none}"
    done
  done
done
