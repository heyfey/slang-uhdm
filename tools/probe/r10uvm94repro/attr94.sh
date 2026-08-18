#!/usr/bin/env bash
# r10uvm94 — ORDER-BLIND, ID-BLIND mover attribution.  Scoreboard/default is a
# ~50/50 COIN per invocation, so every byte-mover is attributed from SORTED,
# id-stripped, workdir-normalised dumps: insertions must equal deletions and
# every changed line must be one the law names.  MEASUREMENT-ONLY.
#   usage: attr94.sh <patched wd> <pristine wd> <rel path...>
set -u
A=${1:?patched wd}; B=${2:?pristine wd}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
norm() { "$DUMP" "$1" 2>/dev/null | sed 1d | sed 's#/tmp/[A-Za-z0-9_]*#WD#g;s/id:[0-9]*//g' | sort; }
for p in "$@"; do
  norm "$A/$p/slang.uhdm" > /tmp/r10uvm94_attr_a.d
  norm "$B/$p/slang.uhdm" > /tmp/r10uvm94_attr_b.d
  ins=$(diff /tmp/r10uvm94_attr_b.d /tmp/r10uvm94_attr_a.d | grep -c '^>'; true)
  del=$(diff /tmp/r10uvm94_attr_b.d /tmp/r10uvm94_attr_a.d | grep -c '^<'; true)
  echo "== $p  order-blind ins=$ins del=$del"
  diff /tmp/r10uvm94_attr_b.d /tmp/r10uvm94_attr_a.d | grep -E '^[<>]' |
    sed 's/, line:.*//' | sed 's/^\(.\) *//' | sort | uniq -c | sort -rn | head -8
done
