#!/usr/bin/env bash
# r10earl118 VERIFIER -- ORDER-BLIND ATTRIBUTION of a byte mover between two
# sweep workdirs: dump both databases, normalise the workdir path out, diff RAW
# and diff SORTED.  A raw-nonzero / order-blind-zero row is an ARENA-ORDER
# mover (the Scoreboard/default COIN); an order-blind-nonzero row is content and
# every line of it must be named.  MEASUREMENT ONLY; uhdm-cmp is the judge.
#
#   WD=<sweep root> A=<side> B=<side> bash attrib_v118.sh <row> [<row>...]
# where <row> is e.g. default/Earlgrey_0_1-71da2fd7 and the databases live at
#   $WD/${A}_sl/<row>/slang.uhdm  and  $WD/${B}_sl/<row>/slang.uhdm
set -u
D=$HOME/git-repos/UHDM/build/bin/uhdm-dump
WD=${WD:-/tmp/vearl118_wd}
A=${A:-pris}; B=${B:-fix}
OUT=${OUT:-/tmp/vearl118_attrib_out}; mkdir -p "$OUT"
for row in "$@"; do
  tag=$(echo "$row" | tr '/' '_')
  for side in $A $B; do
    $D "$WD/${side}_sl/$row/slang.uhdm" 2>/dev/null | sed "s#$WD/${side}_sl##g" > "$OUT/d_${tag}_${side}.txt"
  done
  raw=$(diff "$OUT/d_${tag}_${A}.txt" "$OUT/d_${tag}_${B}.txt" | grep -c '^[<>]' || true)
  sort "$OUT/d_${tag}_${A}.txt" > "$OUT/s_${tag}_${A}.txt"
  sort "$OUT/d_${tag}_${B}.txt" > "$OUT/s_${tag}_${B}.txt"
  ob=$(diff "$OUT/s_${tag}_${A}.txt" "$OUT/s_${tag}_${B}.txt" | grep -c '^[<>]' || true)
  echo "ROW $row A=$A B=$B raw=$raw orderblind=$ob"
  diff "$OUT/s_${tag}_${A}.txt" "$OUT/s_${tag}_${B}.txt" > "$OUT/ob_${tag}.diff" || true
  rm -f "$OUT/d_${tag}_${A}.txt" "$OUT/d_${tag}_${B}.txt" "$OUT/s_${tag}_${A}.txt" "$OUT/s_${tag}_${B}.txt"
done
