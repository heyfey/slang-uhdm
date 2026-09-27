#!/bin/bash
# dumpdist.sh <griddir>: order-blind uhdm-dump line distance golden vs pris and golden vs law
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
w=$1
norm(){ $UHDM_DUMP $1 2>/dev/null | sed -E -e 's#/[^ ,:)]*/([^/ ,:)]+\.(sv|svh|v))#\1#g' -e 's/^[ |]*//' -e 's/, id:[0-9]+//g' -e 's/ id:[0-9]+//g' | sort; }
g=$(ls $w/golden.*.uhdm | head -1)
norm $g > $w/g.nd; norm $w/pris.uhdm > $w/p.nd; norm $w/law.uhdm > $w/l.nd
echo "$(basename $(dirname $w))/$(basename $w) pris=$(python3 $(dirname "${BASH_SOURCE[0]}")/obdist.py $w/g.nd $w/p.nd) law=$(python3 $(dirname "${BASH_SOURCE[0]}")/obdist.py $w/g.nd $w/l.nd) pl=$(python3 $(dirname "${BASH_SOURCE[0]}")/obdist.py $w/p.nd $w/l.nd)"
