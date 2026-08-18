#!/usr/bin/env bash
# r10uvm94 — the RANGE-SELECT census, GOLDEN and OURS, over a whole workdir.
#   usage: cen94.sh <workdir root> <outdir> [--sel|--brk|--all]
# Writes <outdir>/<mode>_<test>.g (golden) and .o (ours) for every row that has
# both databases.  MEASUREMENT-ONLY.
set -u
WD=${1:?workdir root}; OUT=${2:?outdir}; MODE=${3:---sel}
CEN=${CEN:-/tmp/r10uvm94_ct94cen}
JOBS=${JOBS:-4}
mkdir -p "$OUT" || exit 9
L=$(mktemp /tmp/r10uvm94_cenlist.XXXX)
for d in "$WD"/default/*/ "$WD"/testflags/*/; do
  [ -d "$d" ] || continue
  mode=$(basename "$(dirname "$d")"); test=$(basename "$d")
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" 2>/dev/null | head -1)
  [ -n "$G" ] && [ -f "$G/golden.uhdm" ] || continue
  [ -f "$d/slang.uhdm" ] || continue
  printf '%s\t%s\t%s\n' "$OUT/${mode}_${test}" "$G/golden.uhdm" "$d/slang.uhdm"
done > "$L"
echo "pairs=$(wc -l < "$L")"
xargs -a "$L" -P "$JOBS" -d '\n' -I{} sh -c '
  set -- $(printf "%s" "{}" | tr "\t" " ")
  '"$CEN"' "$2" '"$MODE"' > "$1.g" 2>/dev/null
  '"$CEN"' "$3" '"$MODE"' > "$1.o" 2>/dev/null'
rm -f "$L"
echo "done=$(ls "$OUT" | grep -c '\.g$'; true)"
