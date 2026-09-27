#!/bin/bash
# probemovers.sh <new sweep> <pristine sweep> : every probe database that differs byte-wise between two gate sweeps
# (the probe stage keeps <workdir>/probe/<case key>.uhdm); asserts the two path sets are identical.
set -u
A=$1; B=$2
la=$(cd $A/probe && ls *.uhdm | sort); lb=$(cd $B/probe && ls *.uhdm | sort)
[ "$la" = "$lb" ] || { echo PROBE_PATH_SETS_DIFFER; exit 4; }
echo "probe databases: $(echo "$la" | wc -l) (path sets identical)"
n=0; for f in $la; do cmp -s $A/probe/$f $B/probe/$f || { echo "PMOVER $f"; n=$((n+1)); }; done
echo "probe movers: $n"
