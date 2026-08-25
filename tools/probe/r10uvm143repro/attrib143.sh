#!/usr/bin/env bash
# r10uvm143 — ORDER-BLIND ATTRIBUTION of every byte mover.  MEASUREMENT ONLY.
# Dumps both databases, normalises the workdir path away and SORTS, so a
# nondeterministic listing ORDER (Scoreboard/default is a ~50/50 coin) cannot
# masquerade as a change.  Prints every surviving line.
set -u
OUT=${OUT:-/tmp/r10uvm143_s/ATTRIB.txt}
: > "$OUT"
for p in "$@"; do
  A=/tmp/r10uvm143_wdpris/sl/$p/slang.uhdm; B=/tmp/r10uvm143_wdpat/sl/$p/slang.uhdm
  ~/git-repos/UHDM/build/bin/uhdm-dump "$A" 2>/dev/null | sed 's#/tmp/r10uvm143_wdpris#WD#g' | sort > /tmp/r10uvm143_s/.a.d
  ~/git-repos/UHDM/build/bin/uhdm-dump "$B" 2>/dev/null | sed 's#/tmp/r10uvm143_wdpat#WD#g'  | sort > /tmp/r10uvm143_s/.b.d
  n=$(diff /tmp/r10uvm143_s/.a.d /tmp/r10uvm143_s/.b.d | grep -c '^[<>]'; true)
  echo "===== $p  order-blind dump delta: $n lines" >> "$OUT"
  diff /tmp/r10uvm143_s/.a.d /tmp/r10uvm143_s/.b.d >> "$OUT"
done
