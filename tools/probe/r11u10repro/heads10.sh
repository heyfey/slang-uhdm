#!/bin/bash
# r11u8 — per-row cmp head + head count, from a verify_golden workdir.
# uhdm-cmp prints the head to STDERR (a `2>/dev/null` reads every counter 0).
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
  n=$(grep -c '^LHS:' "$OUT/$t.$MODE.err" ; true)
  lines=$(wc -l < "$OUT/$t.$MODE.out")
  head1=$(grep -A2 '^LHS:' "$OUT/$t.$MODE.err" | sed -n 3p)
  printf '%-30s rc=%s heads=%s cmplines=%s HEAD=%s\n' "$t" "$rc" "$n" "$lines" "$head1"
done
exit 0
