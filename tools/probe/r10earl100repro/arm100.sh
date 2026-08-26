#!/usr/bin/env bash
# r10earl100 ARM SCORER — every arm x {plain, elab} x {pristine, patched},
# scored with the OFFICIAL uhdm-cmp against a Surelog golden built here.
# MEASUREMENT ONLY.  Usage: PRISTINE_BIN=... PATCHED_BIN=... bash arm100.sh <outdir>
set -u
PRIS=${PRISTINE_BIN:?}; PAT=${PATCHED_BIN:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:?}; mkdir -p "$OUT"
printf '%-18s %-6s %-9s %8s %6s %8s %6s\n' ARM VIEW BINPAIR PRIS_LINES HEADS PAT_LINES HEADS
for f in "$HERE"/g?_*.sv "$HERE"/a?_*.sv; do
  [ -f "$f" ] || continue
  arm=$(basename "$f" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"
    $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" "$f" > "$d/sl.log" 2>&1 </dev/null
    G=$(find "$d/sl" -name '*.uhdm' | head -1)
    [ -n "$G" ] || { echo "$arm $view NO_GOLDEN"; continue; }
    for side in pris pat; do
      case $side in pris) B=$PRIS;; pat) B=$PAT;; esac
      ( cd "$d" && "$B" $SUF "$f" --nobuiltin -o "$side.uhdm" > "$side.log" 2>&1 </dev/null )
      if [ -f "$d/$side.uhdm" ]; then
        eval "${side}_l=\$($CMP \"\$G\" \"\$d/\$side.uhdm\" 2>/dev/null | wc -l)"
        eval "${side}_h=\$($CMP \"\$G\" \"\$d/\$side.uhdm\" 2>&1 >/dev/null | grep -c '^LHS:' || true)"
        eval "${side}_m=\$(md5sum \"\$d/\$side.uhdm\" | cut -c1-12)"
      else
        eval "${side}_l=REJECT ${side}_h=- ${side}_m=-"
      fi
    done
    same=DIFF; [ "$pris_m" = "$pat_m" ] && same=SAME
    printf '%-18s %-6s %-9s %8s %6s %8s %6s\n' "$arm" "$view" "$same" "$pris_l" "$pris_h" "$pat_l" "$pat_h"
  done
done
