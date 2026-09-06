#!/usr/bin/env bash
# r10uvm177repro/attrib177.sh — ATTRIBUTE each byteverify mover, ORDER-BLIND.
# MEASUREMENT ONLY.  LHS is ALWAYS golden (Surelog); this script compares OUR
# pristine database against OUR patched one, never against golden.
#
#   attrib177.sh <pristine workdir> <patched workdir> <outdir> <relpath> [...]
#
# For each named database it dumps both sides with `uhdm-dump`, normalises the
# WORKDIR out of the text (dump paths embed it), SORTS both dumps and diffs the
# sorted forms — the order-blind reading RESUME §9 requires for the
# Scoreboard/default COIN, whose object ORDER flips ~50/50 per invocation.  A
# coin-only mover shows ZERO order-blind lines; a real mover shows exactly the
# law's lines.  The UNSORTED diff line count is printed beside it so the two
# readings can be told apart.
set -u
PRIS=$(readlink -f "${1:?pristine wd}"); PAT=$(readlink -f "${2:?patched wd}")
OUT=$(readlink -f "${3:?outdir}"); shift 3
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
mkdir -p "$OUT"
for rel in "$@"; do
  a="$PRIS/$rel"; b="$PAT/$rel"
  key=$(echo "$rel" | tr '/' '_')
  if [ ! -f "$a" ] || [ ! -f "$b" ]; then
    echo "SKIP-NOFILE $rel"; continue
  fi
  "$DUMP" "$a" 2>/dev/null | sed "s#$PRIS##g; s#$PAT##g; s/, id:[0-9]*//g" > "$OUT/$key.pris.txt"
  "$DUMP" "$b" 2>/dev/null | sed "s#$PRIS##g; s#$PAT##g; s/, id:[0-9]*//g" > "$OUT/$key.pat.txt"
  raw=$(diff "$OUT/$key.pris.txt" "$OUT/$key.pat.txt" | grep -c '^[<>]' ; true)
  sort "$OUT/$key.pris.txt" > "$OUT/$key.pris.s"; sort "$OUT/$key.pat.txt" > "$OUT/$key.pat.s"
  ob=$(diff "$OUT/$key.pris.s" "$OUT/$key.pat.s" | grep -c '^[<>]' ; true)
  diff "$OUT/$key.pris.s" "$OUT/$key.pat.s" > "$OUT/$key.orderblind.diff" 2>/dev/null
  printf "%-46s raw=%-7s order-blind=%s\n" "$rel" "$raw" "$ob"
done
