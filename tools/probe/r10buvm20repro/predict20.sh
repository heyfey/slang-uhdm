#!/usr/bin/env bash
# r10buvm20repro/predict20.sh — the A-PRIORI mover prediction, from the GOLDEN
# databases ONLY (independent of either of our binaries).  Run on a PRISTINE
# sweep workdir; reads each test's cmds.txt for its golden-cache directory and
# scans that golden with r10buvm20pred.
#
# usage: predict20.sh <sweep-workdir> <pred-binary>
set -u
W=$1; PRED=$2
for c in $(find "$W" -name cmds.txt | sort); do
  d=$(dirname "$c"); t=$(basename "$d"); m=$(basename "$(dirname "$d")")
  g=$(grep -o 'golden cache hit [^)]*' "$c" | head -1 | awk '{print $4}')
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] || continue
  n=$("$PRED" "$g/golden.uhdm" "$t/$m" | grep '^COUNT' | awk '{print $3}')
  [ "${n:-0}" != "0" ] && echo "PREDICT $t $m cells=$n"
done
true
