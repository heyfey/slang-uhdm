#!/bin/bash
# r10ladder1/rowladders.sh — run ctladder over NAMED rows of a verify_golden
# workdir and drop one ladder_<mode>_<name>.txt per row.
#
# LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
#
#   usage: rowladders.sh <workdir> <outdir> <mode:name> [<mode:name> ...]
#
# GUARDS (each one an ops trap this campaign has already paid for):
#   * the golden path is read out of the row's OWN cmds.txt cache-hit line, so
#     the driver cannot silently compare against the wrong golden, and the
#     cache DIRECTORY is turned into .../golden.uhdm (handing a directory to a
#     comparator compares nothing).
#   * BOTH sides are existence-checked and a missing side prints SKIP-NOFILE
#     and is COUNTED — a driver that reaches nothing must never read as
#     perfection.
#   * a name that matches no directory prints UNKNOWN-NAME and is counted.
#   * ctladder's own exit status is captured immediately, not read after a
#     later command substitution has overwritten $?.
#   * the tool is MEASUREMENT-ONLY: this script never claims CMP_EQUAL.  The
#     official uhdm-cmp head is re-taken per row by rowsanity.sh.
set -u
WD=${1:?workdir}
OUT=${2:?outdir}
shift 2
LAD=${CTLADDER:-$(dirname "$0")/ctladder}
[ -x "$LAD" ] || { echo "FATAL: no ctladder at $LAD (build it first)"; exit 3; }
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
mkdir -p "$OUT" || exit 1
MAX=${MAX:-20000}
BUDGET=${BUDGET:-1800}
miss=0; unk=0; done_=0
printf "%-9s %-14s %7s %-18s %10s %8s\n" MODE TEST RUNGS STOP MAXVIS SECS
for spec in "$@"; do
  mode=${spec%%:*}; n=${spec#*:}
  seen=0
  for d in "$WD/$mode/$n"-*/; do
    [ -d "$d" ] || continue
    seen=1
    O=$d/slang.uhdm
    G=""
    [ -f "$d/cmds.txt" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      printf "%-9s %-14s %7s %-18s %10s %8s\n" "$mode" "$n" - "SKIP-NOFILE" - -
      miss=$((miss+1)); continue
    fi
    F=$OUT/ladder_${mode}_${n}.txt
    "$LAD" "$G" "$O" --max="$MAX" --budget="$BUDGET" > "$F" 2>&1
    rc=$?
    S=$(grep -m1 '^\[S\]' "$F")
    printf "%-9s %-14s %7s %-18s %10s %8s  rc=%s\n" "$mode" "$n" \
      "$(sed -n 's/.*rungs=\([0-9]*\).*/\1/p' <<<"$S")" \
      "$(sed -n 's/.*stop=\([A-Z-]*\).*/\1/p' <<<"$S")" \
      "$(sed -n 's/.*maxvis=\([0-9]*\/[0-9]*\).*/\1/p' <<<"$S")" \
      "$(sed -n 's/.*secs=\([0-9.]*\).*/\1/p' <<<"$S")" "$rc"
    done_=$((done_+1))
  done
  [ "$seen" -eq 0 ] && { printf "%-9s %-14s %7s %-18s\n" "$mode" "$n" - UNKNOWN-NAME; unk=$((unk+1)); }
done
echo "-- laddered=$done_  SKIP-NOFILE=$miss  UNKNOWN-NAME=$unk"
