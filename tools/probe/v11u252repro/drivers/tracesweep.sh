#!/bin/bash
# (v11u252: copied from r11u252repro/drivers; run with the fix binary, the v11u252 refinements trace through R11U252_TRACE too)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247, r11u249, r11u250: R11U252_TRACE) tracesweep.sh <law binary> <workroot>: the FIRING CENSUS that is the mover predictor. Runs the law binary
# with R11U252_TRACE over the surelog and uhdm2rtlil corpora (both modes) and the probe cases, every fenced test
# excluded by name through the harness's own --filter (a negative lookahead built from $FENCED, fail-closed), and
# prints one line per (database, law) that fired. Not a gate sweep: its csvs are discarded.
[ -n "$FENCED" ] || { echo "tracesweep.sh: FENCED unset (source drivers/env.sh)" >&2; exit 2; }
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "tracesweep.sh: FENCED not 4 names" >&2; exit 2; }
b=$1; w=$2; [ -x "$b" ] || { echo "tracesweep.sh: binary not executable" >&2; exit 2; }
[ -n "$w" ] || exit 2
REPO=$(cd "$(dirname "$0")/../../../.." && pwd)
alt=$(echo $FENCED | tr ' ' '|')
neg="^(?!(?:$alt)\$)"; negp="^(?!.*\\b(?:$alt)\\b)"
mkdir -p $w/tr
export R11U252_TRACE=$w/tr SLANG_UHDM=$b STRICT_CMP=${STRICT_CMP:?}
cd $REPO
for c in surelog uhdm2rtlil; do
  python3 scripts/verify_golden.py --corpus $c --mode both --jobs 3 --filter "$neg" --out $w/$c.csv --workdir $w/$c > $w/$c.log 2>&1
done
python3 scripts/check_probe.py --jobs 3 --filter "$negp" --out $w/probe.csv --workdir $w/probe > $w/probe.log 2>&1
# one line per database and law: <out path> <law>
for f in $w/tr/*.252; do
  o=$(sed -n '1s/^OUT //p' $f)
  tail -n +2 $f | awk '{print $1}' | sort -u | sed "s#^#$o #"
done | sort -u > $w/firings.txt
wc -l < $w/firings.txt
