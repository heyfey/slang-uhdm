#!/usr/bin/env bash
# r10uvm136 — JOIN-COVERAGE control for wide136.sh.  A multiset join DROPS
# unmatched rows, so a census that reports "9 disagreeing cells" is only honest
# if the two sides carry the SAME cells.  For each named row this prints the
# golden cell count, ours, and the ONE-SIDED counts in both directions.
#   usage: CEN136=.. cover136.sh <workdir> <mode>/<test-prefix> ...
set -u
WD=${1:?workdir}; shift
CEN=${CEN136:?set CEN136}
printf "%-34s %8s %8s %10s %10s\n" ROW GOLDEN OURS ONLY-G ONLY-O
for pat in "$@"; do
  for d in "$WD/$pat"*/; do
    [ -f "$d/slang.uhdm" ] || continue
    g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || continue
    "$CEN" "$g/golden.uhdm" 2>/dev/null | awk -F'\t' '{split($4,v,"|"); print $2"|"$3"|"v[2]}' | sort > /tmp/r10uvm136_cov.g
    "$CEN" "$d/slang.uhdm"  2>/dev/null | awk -F'\t' '{split($4,v,"|"); print $2"|"$3"|"v[2]}' | sort > /tmp/r10uvm136_cov.o
    printf "%-34s %8d %8d %10d %10d\n" "$pat" \
      "$(wc -l < /tmp/r10uvm136_cov.g)" "$(wc -l < /tmp/r10uvm136_cov.o)" \
      "$(comm -23 /tmp/r10uvm136_cov.g /tmp/r10uvm136_cov.o | wc -l)" \
      "$(comm -13 /tmp/r10uvm136_cov.g /tmp/r10uvm136_cov.o | wc -l)"
  done
done
rm -f /tmp/r10uvm136_cov.g /tmp/r10uvm136_cov.o
