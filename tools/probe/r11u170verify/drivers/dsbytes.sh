#!/bin/bash
# dsbytes.sh <downstream workdir> <test>...: byte comparison of the Surelog lane and the slang lane
# (<test>_nohier.il, <test>.il, <test>_synth.v) and the md5 of each pair; the test's csv row.  Fail-closed on $FENCED.
[ -n "$FENCED" ] || { echo "dsbytes.sh: source drivers/env.sh" >&2; exit 2; }
W=$1; shift
for t in "$@"; do
  for n in $FENCED; do [ "$t" = "$n" ] && { echo "FENCED-SKIP"; continue 2; }; done
  r=""
  for f in ${t}_nohier.il $t.il ${t}_synth.v; do
    a=$W/downstream/$t/surelog/$f; b=$W/downstream/$t/slanguh/$f
    if cmp -s $a $b; then r="$r $f=SAME($(md5sum < $a | cut -c1-8),$(wc -c < $a)B)"; else r="$r $f=DIFF"; fi
  done
  echo "$t |$r | $(grep "^$t," $W/downstream.csv)"
done
