#!/bin/bash
# census.sh <lawbin> <outdir>: the firing census of the r11u177 refinements over both corpora (both modes) and the
# probe cases, through the harness with tracewrap.sh standing in for the binary (after r11u169repro/drivers/census.sh).
# FAIL-CLOSED on $FENCED: refuses without the four names; the corpus stages run with a --filter that excludes them
# by whole name, so no fenced row is dispatched.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census.sh: source drivers/env.sh (FENCED) first" >&2; exit 1; }
LAW=$1; O=$2; mkdir -p $O
F="^(?!($(echo $FENCED | tr ' ' '|'))\$)"
D=$(cd $(dirname $0) && pwd)
export LAWBIN=$LAW SLANG_UHDM=$D/tracewrap.sh
cd /tmp/wt_r11u177
CENLOG=$O/census_surelog.log python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$F" --out $O/sl.csv --workdir $O/sl > $O/sl.log 2>&1
CENLOG=$O/census_u2r.log python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$F" --out $O/u2r.csv --workdir $O/u2r > $O/u2r.log 2>&1
CENLOG=$O/census_probe.log python3 scripts/check_probe.py --jobs 3 --out $O/probe.csv --workdir $O/probe > $O/probe.log 2>&1
for f in $FENCED; do grep -cw "$f" $O/census_*.log $O/sl.csv $O/u2r.csv; done | awk -F: '{s+=$NF} END{print "fenced mentions:", s+0}'
echo done
