#!/bin/bash
# r10uvm128/attr128.sh — MEASUREMENT ONLY.  Attributes each byte MOVER by the
# PATH-NORMALISED, ORDER-BLIND dump diff (Scoreboard/default is a ~50/50 COIN
# per invocation — RESUME §9 — so an ordered diff would report the coin, not the
# law), and prints the law's own cells on both sides plus GOLDEN's.
#
# usage: attr128.sh <patchedWorkdir> <pristineWorkdir> <mode/testdir> [...]
set -u
PATW=${1:?}; PRIW=${2:?}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
T=${AWD:-/tmp/r10uvm128_attr}
mkdir -p "$T" || exit 9
for rel in "$@"; do
  key=$(echo "$rel" | tr '/' '_')
  a=$PRIW/$rel/slang.uhdm; b=$PATW/$rel/slang.uhdm
  [ -f "$a" ] && [ -f "$b" ] || { echo "$rel  MISSING"; continue; }
  "$DUMP" "$a" 2>/dev/null </dev/null | sed -e "s#$PRIW##g" -e 's/, id:[0-9]*//g' > "$T/$key.pris"
  "$DUMP" "$b" 2>/dev/null </dev/null | sed -e "s#$PATW##g" -e 's/, id:[0-9]*//g' > "$T/$key.pat"
  ord=$(diff "$T/$key.pris" "$T/$key.pat" | grep -cE '^[<>]'; true)
  sort "$T/$key.pris" > "$T/$key.pris.s"; sort "$T/$key.pat" > "$T/$key.pat.s"
  blind=$(diff "$T/$key.pris.s" "$T/$key.pat.s" | grep -cE '^[<>]'; true)
  echo "$rel  ordered_diff_lines=$ord  ORDER_BLIND_diff_lines=$blind"
  diff "$T/$key.pris.s" "$T/$key.pat.s" | grep -E '^[<>]' | sed 's/^/    /'
done
