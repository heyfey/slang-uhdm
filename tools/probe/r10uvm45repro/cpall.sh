#!/bin/bash
# r10uvm45 — CPTOTAL over the whole UVM-4 in one call (cp.sh is per-test) plus
# the CPCLASS sub-class, so a PRE/POST pair is two commands instead of ten.
#   usage: cpall.sh <sweep-workdir> <tag>
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
WD=${1:?}
TAG=${2:?}
tot=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  L=$("$HERE"/cp.sh "$WD" "$TAG" "$T")
  echo "$L"
  n=$(printf '%s\n' "$L" | grep -oE 'diff=[0-9]+' | cut -d= -f2)
  # A driver that cannot find its probe reports perfection — refuse to add a
  # blank or a zero that came from an empty census.
  g=$(printf '%s\n' "$L" | grep -oE 'golden=[0-9]+' | cut -d= -f2)
  [ -n "$g" ] && [ "$g" -gt 0 ] || { echo "FATAL: $T golden census EMPTY"; exit 3; }
  tot=$((tot + n))
done
echo "CPTOTAL[$TAG] = $tot"
"$HERE"/cpclass.sh "$TAG"
