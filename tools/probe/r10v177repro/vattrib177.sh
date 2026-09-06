#!/usr/bin/env bash
# r10v177repro/vattrib177.sh — attribute every byte mover ORDER-BLIND.
#
#   vattrib177.sh <pristine sweep root> <patched sweep root> <outdir> <rel> ...
#
# RESUME §9 forbids attributing Scoreboard/default any other way: that row is a
# ~50/50 COIN per invocation, so a RAW dump diff there reads ~82 lines of pure
# ordering.  Both dumps are therefore normalised (the workdir path and every
# `id:NNN` removed) and SORTED before diffing, which cancels ordering entirely.
# RAW and ORDER-BLIND counts are both printed: raw-minus-order-blind is the
# coin, order-blind is the law.
set -u
A=${1:?pristine root}; B=${2:?patched root}; OUT=${3:?outdir}; shift 3
DUMP=$HOME/.local/bin/uhdm-dump
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
norm() { sed -e "s#$A##g" -e "s#$B##g" -e 's/, id:[0-9]*//g' -e 's/id:[0-9]*//g'; }
for rel in "$@"; do
  k=$(echo "$rel" | tr '/' '_')
  "$DUMP" "$A/$rel" 2>/dev/null | norm > "$OUT/$k.a"
  "$DUMP" "$B/$rel" 2>/dev/null | norm > "$OUT/$k.b"
  raw=$(diff "$OUT/$k.a" "$OUT/$k.b" | grep -c '^[<>]'; true)
  sort "$OUT/$k.a" > "$OUT/$k.as"; sort "$OUT/$k.b" > "$OUT/$k.bs"
  ob=$(diff "$OUT/$k.as" "$OUT/$k.bs" | grep -c '^[<>]'; true)
  echo "== $rel  raw=$raw  order-blind=$ob"
  diff "$OUT/$k.as" "$OUT/$k.bs" | grep '^[<>]' | sed 's/^/    /'
  rm -f "$OUT/$k.a" "$OUT/$k.b" "$OUT/$k.as" "$OUT/$k.bs"
done
