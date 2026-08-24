#!/usr/bin/env bash
# r10uvm117repro/movattrib117.sh — ORDER-BLIND BYTE-MOVER ATTRIBUTION.
# MEASUREMENT ONLY.  LHS is ALWAYS golden; here the two sides are OUR OWN
# pristine and patched databases, and the question is WHICH OBJECTS changed.
#
#   movattrib117.sh <patched workdir> <pristine workdir> <outdir> <mode/name> ...
#
# uhdm-dump both databases, NORMALISE the embedded workdir path and every
# object id away, SORT (Scoreboard/default is a ~50/50 emitter COIN — RESUME
# §9 — so only an order-blind read can attribute it), and diff.  A mover whose
# sorted diff is EMPTY is the coin and nothing else.
set -u
Q=${1:?patched workdir}; P=${2:?pristine workdir}; OUT=${3:?outdir}; shift 3
mkdir -p "$OUT"
norm() { sed -e 's#/tmp/[^ ,)]*/slang\.uhdm#<DB>#g' -e 's#, id:[0-9]*##g' \
             -e 's#id:[0-9]*##g' -e "s#$Q#<WD>#g" -e "s#$P#<WD>#g"; }
for mn in "$@"; do
  qd="$Q/$mn"; pd="$P/$mn"
  [ -f "$qd/slang.uhdm" ] && [ -f "$pd/slang.uhdm" ] || { echo "== $mn SKIP-NOFILE"; continue; }
  uhdm-dump "$qd/slang.uhdm" 2>&1 | norm > "$OUT/$(echo "$mn" | tr / _).q.txt"
  uhdm-dump "$pd/slang.uhdm" 2>&1 | norm > "$OUT/$(echo "$mn" | tr / _).p.txt"
  k=$(echo "$mn" | tr / _)
  raw=$(diff "$OUT/$k.p.txt" "$OUT/$k.q.txt" | grep -c '^[<>]')
  sort "$OUT/$k.p.txt" > "$OUT/$k.p.sorted"; sort "$OUT/$k.q.txt" > "$OUT/$k.q.sorted"
  ord=$(diff "$OUT/$k.p.sorted" "$OUT/$k.q.sorted" | grep -c '^[<>]')
  echo "== $mn  raw-diff-lines=$raw  ORDER-BLIND-diff-lines=$ord"
  diff "$OUT/$k.p.sorted" "$OUT/$k.q.sorted" > "$OUT/$k.orderblind.diff" 2>&1
  [ "$ord" -gt 0 ] && sed -n '1,80p' "$OUT/$k.orderblind.diff"
  true
done
