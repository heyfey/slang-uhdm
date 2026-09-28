#!/bin/bash
# dsnet.sh <downstream workdir> <test>...: per test, the md5 of the Surelog lane's and the slang lane's _nohier.il,
# .il and _synth.v (scripts/downstream_uhdm2rtlil.py keeps both lanes: <test>/surelog, <test>/slanguh) and whether
# each pair is byte-identical.  Refuses a fenced name (fail-closed on $FENCED).
source "$(dirname "$0")/env.sh" || exit 2
W=$1; shift
for t in "$@"; do
  echo "$t" | grep -Pq "$FENCE_RE" && { echo "$t fenced refused"; continue; }
  out="$t"; for s in _nohier.il .il _synth.v; do a=$(md5sum < $W/$t/surelog/$t$s | cut -c1-10); b=$(md5sum < $W/$t/slanguh/$t$s | cut -c1-10)
    out="$out $s:$a/$b:$([ $a = $b ] && echo SAME || echo DIFF)"; done; echo "$out"
done
