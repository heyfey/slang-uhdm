#!/bin/bash
# v11u209: grid.sh <tag> <binary> [ENV=VAL...] -- every case under cases/ (or the dirs listed in $LIST), both views
# (parse and -elabuhdm), 3 at a time; one case.sh line per case-view on stdout.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
t=$1; b=$2; shift 2
L=${LIST:-$(mktemp /tmp/v11u209_list.XXXX)}
[ -n "$LIST" ] || find $V209/cases -name dut.sv -printf '%h\n' | sort > $L
run(){ c=$1; shift; bash $HERE/case.sh $c $t $b "$@"; EL=1 bash $HERE/case.sh $c $t $b "$@"; }
export -f run; export t b HERE
xargs -a $L -P 3 -I{} bash -c "run {} $*" </dev/null
