#!/bin/bash
# (copy of r11u174repro/drivers/census.sh) census.sh <lawbin> <outdir>: the firing census of every law of this pass over both corpora (both
# modes) and the probe cases, run through the harness with tracewrap.sh standing in for the binary.
# FAIL-CLOSED on $FENCED: refuses to run without the four names, and the corpus stages run with a
# --filter that excludes them by whole name, so no fenced row is dispatched.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "census.sh: export FENCED (four names) first" >&2; exit 1; }
LAW=$1; O=$2; mkdir -p $O
F="^(?!($(echo $FENCED | tr ' ' '|'))\$)"
D=$(cd $(dirname $0) && pwd); R=$(cd $D/../../../.. && pwd)
export LAWBIN=$LAW SLANG_UHDM=$D/tracewrap.sh
cd $R
CENLOG=$O/census_surelog.log python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$F" --out $O/sl.csv --workdir $O/sl > $O/sl.log 2>&1
CENLOG=$O/census_u2r.log python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$F" --out $O/u2r.csv --workdir $O/u2r > $O/u2r.log 2>&1
CENLOG=$O/census_probe.log python3 scripts/check_probe.py --jobs 3 --out $O/probe.csv --workdir $O/probe > $O/probe.log 2>&1
for f in $FENCED; do grep -cw "$f" $O/census_*.log $O/sl.csv $O/u2r.csv; done | awk -F: '{s+=$NF} END{print "fenced mentions:", s+0}'
echo done
