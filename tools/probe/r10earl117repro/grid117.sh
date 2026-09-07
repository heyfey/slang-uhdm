#!/usr/bin/env bash
# r10earl117 GRID DRIVER -- MEASUREMENT ONLY.  Builds golden + ours for each arm
# in both views and runs sig117 on all three databases.
#   PRISTINE_BIN=<bin> [PATCHED_BIN=<bin>] ARM_DIR=<dir> bash grid117.sh <outdir> [arm.sv ...]
# GUARDS (each one an ops trap this campaign has paid for):
#   * every producer's rc is RECORDED, never inferred from a missing file;
#   * children get </dev/null so a child cannot eat the driver's stdin;
#   * the -top is read from TOPS.txt keyed on the arm BASENAME;
#   * a missing database prints REJECT and is COUNTED;
#   * sig117's own `CENRC 0` accounting line is asserted for all three sides.
set -u
PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
PAT=${PATCHED_BIN:-$PRIS}
SIG=${SIG_BIN:?set SIG_BIN}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
ARMD=${ARM_DIR:?set ARM_DIR}
TOPS=${TOPS_FILE:-$ARMD/TOPS.txt}
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
FILES=("$@"); [ ${#FILES[@]} -eq 0 ] && FILES=("$ARMD"/*.sv)
printf '%-18s %-6s %5s %5s %5s %10s %10s\n' ARM VIEW SLRC PRC ARC "PRIS c/h" "PATCH c/h"
for f0 in "${FILES[@]}"; do
  f=$f0; case "$f" in /*) ;; *) f="$ARMD/$f0";; esac
  [ -f "$f" ] || { echo "MISSING $f0"; continue; }
  arm=$(basename "$f" .sv)
  t=$(awk -v a="$arm" '$1==a{print $2}' "$TOPS" 2>/dev/null | head -1)
  T=""; U=""; [ -n "$t" ] && { T="-top $t"; U="--top $t"; }
  for view in plain elab; do
    case $view in
      plain) SLF="-parse";            SUF="";;
      elab)  SLF="-parse -elabuhdm";  SUF="--elabuhdm";;
    esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
    ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl $T "$f" > sl.log 2>&1 </dev/null ); slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$PRIS" $SUF $U "$f" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && "$PAT"  $SUF $U "$f" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
      printf '%-18s %-6s %5s %5s %5s %10s %10s  REJECT\n' "$arm" "$view" "$slrc" "$prc" "$arc" - -
      continue
    fi
    "$CMP" "$G" "$d/pris.uhdm"    > "$d/pris.cmp" 2>&1
    "$CMP" "$G" "$d/patched.uhdm" > "$d/patch.cmp" 2>&1
    pc=$(wc -l < "$d/pris.cmp");  ph=$(grep -c '^LHS:' "$d/pris.cmp"; true)
    ac=$(wc -l < "$d/patch.cmp"); ah=$(grep -c '^LHS:' "$d/patch.cmp"; true)
    printf '%-18s %-6s %5s %5s %5s %10s %10s\n' "$arm" "$view" "$slrc" "$prc" "$arc" "$pc/$ph" "$ac/$ah"
    "$SIG" "$G"              "${arm}_${view}" > "$d/sig.gold.txt"  2>&1
    "$SIG" "$d/pris.uhdm"    "${arm}_${view}" > "$d/sig.pris.txt"  2>&1
    "$SIG" "$d/patched.uhdm" "${arm}_${view}" > "$d/sig.patch.txt" 2>&1
    for c in gold pris patch; do
      r=$(sed -n 's/^CENRC //p' "$d/sig.$c.txt")
      [ "$r" = "0" ] || echo "  CENRC-BAD $arm $view $c rc=${r:-none}"
    done
  done
done
