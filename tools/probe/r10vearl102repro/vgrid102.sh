#!/usr/bin/env bash
# v102 VERIFIER GRID -- MEASUREMENT ONLY.  OURS_BIN=<bin> bash vgrid102.sh <outdir> <arm.sv>...
set -u
OURS=${OURS_BIN:?set OURS_BIN}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
printf '%-16s %-6s %6s %6s %9s %6s\n' ARM VIEW SLRC OURRC CMPLINES HEADS
while IFS= read -r f <&3; do
  [ -f "$f" ] || continue
  arm=$(basename "$f" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"
    $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o "$d/sl" "$f" > "$d/sl.log" 2>&1 </dev/null
    slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$OURS" $SUF "$f" --nobuiltin -o ours.uhdm > ours.log 2>&1 </dev/null )
    ourc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/ours.uhdm" ]; then
      printf '%-16s %-6s %6s %6s %9s %6s\n' "$arm" "$view" "$slrc" "$ourc" REJECT -
      continue
    fi
    echo "$G" > "$d/goldpath"
    L=$($CMP "$G" "$d/ours.uhdm" 2>/dev/null | wc -l)
    H=$($CMP "$G" "$d/ours.uhdm" 2>&1 >/dev/null | grep -c '^LHS:' || true)
    $CMP "$G" "$d/ours.uhdm" > "$d/cmp.out" 2> "$d/cmp.head"
    printf '%-16s %-6s %6s %6s %9s %6s\n' "$arm" "$view" "$slrc" "$ourc" "$L" "$H"
  done
done 3< <(printf '%s\n' "$@")
