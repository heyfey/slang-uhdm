#!/bin/bash
# r11u1: per-test interface_inst param census, GOLDEN vs OURS.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}; shift 2
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
for n in "$@"; do
  for d in "$WD/default/$n"-*/; do
    [ -d "$d" ] || continue
    C=$d/cmds.txt; O=$d/slang.uhdm
    G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && G=$G/golden.uhdm
    [ -f "$G" ] && [ -f "$O" ] || { echo "$n SKIP-NOFILE"; continue; }
    $DUMP "$G" > "$OUT/$n.g.dump" 2>/dev/null
    $DUMP "$O" > "$OUT/$n.o.dump" 2>/dev/null
    python3 "$(dirname "$(readlink -f "$0")")/ifcen.py" "$OUT/$n.g.dump" | sort -u > "$OUT/$n.g.cen"
    python3 "$(dirname "$(readlink -f "$0")")/ifcen.py" "$OUT/$n.o.dump" | sort -u > "$OUT/$n.o.cen"
    echo "### $n"
    diff <(grep -v 'par=0 pa=0' "$OUT/$n.g.cen") <(grep -v 'par=0 pa=0' "$OUT/$n.o.cen") | sed 's/^/  /'
  done
done
