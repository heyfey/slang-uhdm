#!/usr/bin/env bash
# v100 adversarial arm scorer.  MEASUREMENT ONLY; judge = official uhdm-cmp.
set -u
PRIS=${PRISTINE_BIN:?}; PAT=${PATCHED_BIN:?}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SRC=${SRCDIR:?}
OUT=${1:?}; mkdir -p "$OUT"
printf '%-18s %-6s %-6s %8s %6s %8s %6s\n' ARM VIEW BINPAIR PRIS_LINES HEADS PAT_LINES HEADS
for f in "$SRC"/*.sv; do
  [ -f "$f" ] || continue
  arm=$(basename "$f" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"
    $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" "$f" > "$d/sl.log" 2>&1 </dev/null
    G=$(find "$d/sl" -name '*.uhdm' | head -1)
    [ -n "$G" ] || { echo "$arm $view NO_GOLDEN"; continue; }
    echo "$G" > "$d/golden.path"
    for side in pris pat; do
      case $side in pris) B=$PRIS;; pat) B=$PAT;; esac
      ( cd "$d" && "$B" $SUF "$f" --nobuiltin -o "$side.uhdm" > "$side.log" 2>&1 </dev/null ); echo "rc=$? $side" >> "$d/rc.txt"
      if [ -f "$d/$side.uhdm" ]; then
        $CMP "$G" "$d/$side.uhdm" > "$d/$side.cmp" 2> "$d/$side.head"
        eval "${side}_l=\$(wc -l < \"\$d/\$side.cmp\")"
        eval "${side}_h=\$(grep -c '^LHS:' \"\$d/\$side.head\" || true)"
        eval "${side}_m=\$(md5sum \"\$d/\$side.uhdm\" | cut -c1-12)"
      else
        eval "${side}_l=REJECT; ${side}_h=-; ${side}_m=-"
      fi
    done
    same=DIFF; [ "$pris_m" = "$pat_m" ] && same=SAME
    printf '%-18s %-6s %-6s %8s %6s %8s %6s\n' "$arm" "$view" "$same" "$pris_l" "$pris_h" "$pat_l" "$pat_h"
  done
done
