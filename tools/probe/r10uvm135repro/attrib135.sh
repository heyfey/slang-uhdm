#!/usr/bin/env bash
# r10uvm135repro/attrib135.sh — ORDER-BLIND line attribution for ONE mover.
# MEASUREMENT ONLY.  Dump paths embed the workdir, so both dumps are normalised
# before the sort/diff (RESUME §9); the sort makes the comparison order-blind,
# which is the only safe reading for a row whose emitter order can flip.
#   attrib135.sh <pristine db> <patched db> [label]
set -u
export LC_ALL=C
P=${1:?pristine.uhdm}; Q=${2:?patched.uhdm}; L=${3:-mover}
T=$(mktemp -d /tmp/r10uvm135_attrib.XXXXXX)
norm() { sed -e '1s#^[^:]*\.uhdm:#<DB>:#' -e 's#/tmp/[A-Za-z0-9_.]*/##g' -e 's#, id:[0-9]*##g'; }
uhdm-dump "$P" 2>&1 | norm | LC_ALL=C sort > "$T/p.txt"
uhdm-dump "$Q" 2>&1 | norm | LC_ALL=C sort > "$T/q.txt"
add=$(comm -13 "$T/p.txt" "$T/q.txt" | wc -l)
rem=$(comm -23 "$T/p.txt" "$T/q.txt" | wc -l)
echo "== $L  ADDED=$add REMOVED=$rem"
echo "-- ADDED:"; comm -13 "$T/p.txt" "$T/q.txt" | sed 's/^/   /'
echo "-- REMOVED:"; comm -23 "$T/p.txt" "$T/q.txt" | sed 's/^/   /'
rm -rf "$T"
