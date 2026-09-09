#!/bin/bash
# r11v11u5 — per-row cmp head + cmp line count, from a verify_golden workdir.
CMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-cmp
WD=${1:?workdir}
MODE=${2:?mode}
OUT=${3:?outdir}
mkdir -p "$OUT"
shift 3
for t in "$@"; do
  d=$(ls -d "$WD/$MODE/$t"-* 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "$t MISSING"; continue; }
  g=$(grep -o 'golden cache hit [^)]*' "$d/cmds.txt" | head -1 | sed 's/golden cache hit //')
  gf="$g/golden.uhdm"
  [ -f "$gf" ] || gf=$(ls "$g"/*.uhdm 2>/dev/null | head -1)
  $CMP "$gf" "$d/slang.uhdm" > "$OUT/$t.$MODE.out" 2> "$OUT/$t.$MODE.err"
  rc=$?
  n=$(grep -c '^LHS:' "$OUT/$t.$MODE.out" ; true)
  lines=$(wc -l < "$OUT/$t.$MODE.out")
  head1=$(grep -A1 '^LHS:' "$OUT/$t.$MODE.out" | sed -n 2p)
  printf '%-26s rc=%s heads=%s cmplines=%s HEAD=%s\n' "$t" "$rc" "$n" "$lines" "$head1"
done
