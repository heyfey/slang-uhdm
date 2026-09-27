#!/bin/bash
# rec.sh <rel>: full strict record lists for P and L and movement
source $(dirname "${BASH_SOURCE[0]}")/env.sh
w=/tmp/v11u181_g/$1
$STRICT_CMP --max 100000 $w/gold/golden.uhdm $w/P.uhdm > $w/P.full 2>&1
$STRICT_CMP --max 100000 $w/gold/golden.uhdm $w/L.uhdm > $w/L.full 2>&1
echo "== $1 P:$(tail -1 $w/P.full) L:$(tail -1 $w/L.full)"; python3 /tmp/v11u181_recmv.py $w/P.full $w/L.full
