#!/bin/bash
# v11u302 bvlanes.sh <workdir A> <workdir B>: byte comparison of the probe databases (probe/*.uhdm) and the downstream
# lane's slang databases (downstream/<test>/slang.uhdm) of two sweeps; the path lists are built first and filtered by
# $FENCED (word boundary) before any file is opened; prints every differing path and the totals.
source "$(dirname "$0")/env.sh" || exit 3
A=$1; B=$2
for lane in probe downstream; do
  la=$(mktemp); lb=$(mktemp)
  if [ $lane = probe ]; then (cd $A && find probe -maxdepth 1 -name '*.uhdm' | sort) > $la; (cd $B && find probe -maxdepth 1 -name '*.uhdm' | sort) > $lb
  else (cd $A && find downstream -mindepth 2 -maxdepth 2 -name slang.uhdm | sort) > $la; (cd $B && find downstream -mindepth 2 -maxdepth 2 -name slang.uhdm | sort) > $lb; fi
  grep -vP "$FENCERE" $la > $la.f; grep -vP "$FENCERE" $lb > $lb.f
  diff -q $la.f $lb.f > /dev/null || { echo "$lane PATH_SETS_DIFFER"; diff $la.f $lb.f | head -5; }
  n=0; m=0
  while read -r p; do n=$((n+1)); [ -f "$B/$p" ] || continue; cmp -s "$A/$p" "$B/$p" || { m=$((m+1)); echo "$lane DIFF $p"; }; done < $la.f
  echo "$lane: $m of $n differ (fenced filtered: $(( $(wc -l < $la) - $(wc -l < $la.f) )))"
  rm -f $la $lb $la.f $lb.f
done
