#!/usr/bin/env bash
# r10uvm136 — MOVER ATTRIBUTION.  For each byte mover, dump both databases,
# NORMALISE the workdir path out (dump paths embed the workdir), sort both, and
# diff ORDER-BLIND.  Scoreboard/default is a ~50/50 COIN per invocation, so
# order-blind is the ONLY sound attribution there (RESUME §9).
#   usage: attr136.sh <patched-wd> <pristine-wd> <out> <relpath> ...
set -u
A=$(readlink -f "${1:?}"); B=$(readlink -f "${2:?}"); OUT=$(readlink -f "${3:?}"); shift 3
D=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$OUT"
printf "%-40s %8s %8s %s\n" ROW OUT IN VERDICT
for rel in "$@"; do
  k=$(echo "$rel" | tr '/' '_')
  "$D" "$B/$rel" 2>/dev/null | sed "s#$B##g;s#$A##g" | sort > "$OUT/$k.pris"
  "$D" "$A/$rel" 2>/dev/null | sed "s#$B##g;s#$A##g" | sort > "$OUT/$k.pat"
  diff "$OUT/$k.pris" "$OUT/$k.pat" > "$OUT/$k.diff"
  o=$(grep -c '^<' "$OUT/$k.diff"; true); i=$(grep -c '^>' "$OUT/$k.diff"; true)
  # the law's OWN lines: the bit_var -> struct_var swap on mem_range and nothing else
  bad=$(grep -E '^[<>]' "$OUT/$k.diff" | grep -vcE 'mem_range'; true)
  V=LAW-ONLY; [ "$bad" != 0 ] && V="OFF-LAW($bad lines)"
  printf "%-40s %8s %8s %s\n" "$rel" "$o" "$i" "$V"
done
