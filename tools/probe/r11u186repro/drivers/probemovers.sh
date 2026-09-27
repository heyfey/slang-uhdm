#!/bin/bash
# r11u186: the probe-case byte movers between two sweeps (the <workdir>/probe/<case>.uhdm databases of
# check_probe.py): prints `MOVER <case>` per differing database, then the count; asserts the two path sets agree.
# usage: probemovers.sh <law workdir> <pristine workdir>
A=$1/probe; B=$2/probe
diff -q <(cd $A && ls *.uhdm | sort) <(cd $B && ls *.uhdm | sort) > /dev/null || { echo PATH_SETS_DIFFER; exit 4; }
n=0; m=0
for f in $(cd $A && ls *.uhdm | sort); do n=$((n+1)); cmp -s $A/$f $B/$f || { m=$((m+1)); echo "MOVER ${f%.uhdm}" | sed 's/__/\//g'; }; done
echo "PROBE MOVERS: $m / $n"
