#!/bin/bash
# dumpdiff.sh <case workdir under $GW> <tag> : uhdm-dump golden and ours (id-stripped, path-normalised) and diff them.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
w=$1; t=${2:-pris}
g=$(ls $w/gold_*/golden.uhdm | head -1)
$UHDM_DUMP $g 2>/dev/null | sed 's/, id:[0-9]*//; s#file:[^,]*/##' > $w/g.dump
$UHDM_DUMP $w/$t.uhdm 2>/dev/null | sed 's/, id:[0-9]*//; s#file:[^,]*/##' > $w/$t.dump
diff $w/g.dump $w/$t.dump | tail -n +5
