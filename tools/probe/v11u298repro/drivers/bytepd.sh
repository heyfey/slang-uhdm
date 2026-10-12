#!/bin/bash
# v11u298 bytepd.sh <new sweep wd> <old sweep wd>: byte movers of the probe databases and the downstream slang-lane
# databases between two sweeps; path lists built first and filtered by $FENCED before any file is opened.
source "$(dirname "$0")/env.sh" || exit 3
A=$1; B=$2
n=0; m=0; while read -r p; do n=$((n+1)); cmp -s "$A/probe/$p" "$B/probe/$p" || { m=$((m+1)); echo "PROBE_MOVER $p"; }; done < <(cd $A/probe && ls | grep '\.uhdm$' | grep -vP "$FENCERE" | sort)
echo "probe movers $m / $n"
n=0; m=0; while read -r p; do n=$((n+1)); cmp -s "$A/downstream/$p" "$B/downstream/$p" || { m=$((m+1)); echo "DS_MOVER $p"; }; done < <(cd $A/downstream && find . -maxdepth 2 -name slang.uhdm | grep -vP "$FENCERE" | sort)
echo "downstream slang-lane movers $m / $n"
