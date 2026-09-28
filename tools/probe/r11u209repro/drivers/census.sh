#!/bin/bash
# r11u209 (from r11u205dec): the FIRING CENSUS (the mover predictor), frozen before the law sweep.
# Runs the law binary with R11U209_TRACE (which also carries the three r11u205 laws this pass lands) over the probe
# cases and both corpora in both modes, the corpus runs filtered to exclude the four fenced tests (names from $FENCED,
# fail closed), then names every row-mode / case where a law of this pass FIRED.
# usage: census.sh <law binary> <workdir>   -> <workdir>/predicted.txt, <workdir>/firings.txt
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
LB=$1; W=$2; [ -x "$LB" ] && [ -n "$W" ] || { echo "usage: census.sh <bin> <wd>"; exit 2; }
rm -rf $W; mkdir -p $W/trace
FILT="^(?!($FENCE_RE)\$)"
cd $REPO
export SLANG_UHDM=$LB R11U209_TRACE=$W/trace
unset GOLDEN_DEFER R11U205_TRACE
python3 scripts/check_probe.py --jobs 3 --workdir $W/probe --out $W/probe.csv > $W/probe.log 2>&1
for c in surelog uhdm2rtlil; do
  python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$FILT" --out $W/$c.csv --workdir $W/$c > $W/$c.log 2>&1
done
for f in $W/trace/*; do
  out=$(head -1 $f | sed 's/^OUT //')
  sed 1d $f | awk '{print $1}' | sort -u | while read law; do echo "$out $law"; done
done | sed -E "s#^$W/(surelog|uhdm2rtlil)/(default|testflags)/(.*)-[0-9a-f]+/slang.uhdm#\1 \2 \3#; s#^$W/probe/(.*)\.uhdm#probe - \1#" | sort -u > $W/firings.txt
awk '{print $1, $2, $3}' $W/firings.txt | sort -u > $W/predicted.txt
echo "firings: $(wc -l < $W/firings.txt) predicted row-modes/cases: $(wc -l < $W/predicted.txt)"
for n in $FENCED; do grep -cw "$n" $W/predicted.txt; done | paste -sd' ' | sed 's/^/fenced hits (must be 0 0 0 0): /'
